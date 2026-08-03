{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  ai-starship-config = pkgs.writeText "starship.toml" ''
    [username]
    show_always = true
    style_user = "bold purple"
    format = '[$user]($style)'
  '';

  # The sandbox users share eox's herdr config rather than getting their own.
  # This is a live path, not a store copy: `herdr` lives outside the flake root
  # (which is ./nixos), so Nix cannot copy it in, and pointing at the real file
  # means an edit here reaches every herdr on the next launch without a rebuild.
  # The trade-off is that the ACL services below become load-bearing — revoke a
  # group's read access to this tree and that sandbox's herdr loses its config.
  eox-herdr-config = "/home/eox/.dotfiles/herdr/.config/herdr/config.toml";

  # Traverse-only (x, no r) gates: each group can walk *through* these parents
  # to reach the tree granted to it by mkExternalAclService below, but cannot
  # list their contents. Useless on their own — a group needs both halves.
  #
  # Single source of truth because both halves consume it. The oneshot units
  # apply it so a manual `systemctl restart acl-*` is self-sufficient, and
  # sandboxTraverseAcls reapplies it on every activation; see the comment there
  # for why the units alone are not enough.
  traverseAcls = {
    claude_workspace = [ "/home/eox" ];
    opencode_workspace = [
      "/home/eox"
      "/home/eox/.dotfiles"
    ];
  };

  # One-shot service that establishes the access + default ACLs on a
  # shared workspace. Default ACLs propagate to all *future* files/dirs,
  # so this is self-maintaining for source code and build artifacts.
  # It deliberately does NOT touch tool state — that lives elsewhere.
  mkWorkspaceAclService = { dir, group }: {
    description = "Set default ACLs on ${dir} for group ${group}";
    after = [ "systemd-tmpfiles-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Don't abort the whole service if a single file can't take an ACL.
      set +e

      # Default ACL on the root: new files/dirs inherit group rwx automatically.
      ${pkgs.acl}/bin/setfacl -m  d:g:${group}:rwx  ${dir}
      ${pkgs.acl}/bin/setfacl -m    g:${group}:rwx  ${dir}

      # Retroactive pass for pre-existing regular files/dirs, excluding .devenv
      # (PostgreSQL state must stay 0700 with no group ACL). -P keeps find from
      # following symlinks, and we only target real files and dirs.
      ${pkgs.findutils}/bin/find -P ${dir} \
        -name .devenv -prune -o \
        \( -type f -o -type d \) -print0 \
        | ${pkgs.findutils}/bin/xargs -0 -r ${pkgs.acl}/bin/setfacl -m g:${group}:rwx

      ${pkgs.findutils}/bin/find -P ${dir} \
        -name .devenv -prune -o \
        -type d -print0 \
        | ${pkgs.findutils}/bin/xargs -0 -r ${pkgs.acl}/bin/setfacl -m d:g:${group}:rwx

      # Always succeed — ACLs are best-effort here, and the default ACL on the
      # root is what actually keeps things working going forward.
      exit 0
    '';
  };

  # One-shot service that grants a group access to a tree *outside* the shared
  # workspaces, so a sandboxed agent can reach config it is asked to work on.
  # perms defaults to rX — read plus directory traversal, no write. Capital X
  # applies execute to directories only, so regular files stay r-- rather than
  # becoming executable; rwX widens that to write while keeping the same rule.
  mkExternalAclService =
    {
      traverse,
      dir,
      group,
      perms ? "rX",
    }:
    {
      description = "Grant ${group} ${perms} ACLs on ${dir}";
      after = [ "systemd-tmpfiles-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Don't abort the whole service if a single file can't take an ACL.
        set +e

        # The gates on the way down to ${dir}. Also reapplied by
        # system.activationScripts.sandboxTraverseAcls — repeated here so that
        # restarting this unit by hand is enough to repair the whole grant.
        ${pkgs.acl}/bin/setfacl -m g:${group}:x ${builtins.concatStringsSep " " traverse}

        # Access on the tree itself, plus a default ACL so files added later
        # inherit it. setfacl -R does not follow symlinks, which matters here
        # because this tree is stow-managed and full of them.
        ${pkgs.acl}/bin/setfacl -R -m  g:${group}:${perms} ${dir}
        ${pkgs.acl}/bin/setfacl -R -m d:g:${group}:${perms} ${dir}

        # Always succeed — ACLs are best-effort, and the default ACL on the root
        # is what keeps things working going forward.
        exit 0
      '';
    };

  # One-shot service that installs herdr's official integration for a sandboxed
  # agent. The integration reports session identity over that user's herdr
  # socket, which is what [session] resume_agents_on_restore needs to put panes
  # back into their real conversations. It runs as the sandbox user so the hook
  # lands in that user's tree and can reach that user's socket — installing it
  # as eox would write to the wrong home and hit a socket the agent can't use.
  mkAgentIntegrationService =
    {
      user,
      agent,
      configDir,
      env ? { },
    }:
    {
      description = "Install herdr's ${agent} integration for ${user}";
      after = [ "systemd-tmpfiles-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = user;
      };
      environment = env;
      script = ''
        # The installer refuses to run if the agent's config dir does not exist.
        mkdir -p ${configDir}
        ${pkgs-unstable.herdr}/bin/herdr integration install ${agent}
      '';
    };

  # Shared launcher logic. Per-user devenv state is the crux of the fix:
  # PostgreSQL (and ssh/gpg) need a 0700 dir they own, which is impossible
  # inside a group-shared tree, so we redirect devenv state into $HOME.
  #
  # herdr replaces tmux here. Unlike tmux it takes no startup command, so this
  # drops you into the herdr UI rather than straight into the agent; spawn
  # agents from there. Running herdr *inside* the sandbox rather than around it
  # is what makes agent detection work: same uid, no sudo boundary in the pane's
  # process tree, and nothing else painting over the pane's bottom rows.
  # `umask 002` must stay ahead of it — herdr's panes inherit it, and that is
  # what keeps new files group-writable for the workspace ACLs.
  mkSandbox =
    {
      name,
      user,
      group,
      workspace,
    }:
    let
      # This half runs as ${user}, and lives in its own file for a reason:
      # `sudo -i` joins its command argv with spaces and re-parses the result
      # through the target user's login shell. An inline multi-line script does
      # not survive that round trip — the quoting is gone by the time the login
      # shell sees it. A single store path plus one argument does survive.
      #
      # `$*` rather than `$1`: sudo joined the argv with spaces on the way in,
      # so re-joining reverses it and a workspace path containing spaces still
      # arrives intact.
      inner = pkgs.writeShellScript "${name}-sandbox-inner" ''
        umask 002
        if ! cd "$*" 2>/dev/null; then
          echo '⚠️  No access to current directory. Dropping into default workspace...'
          cd '${workspace}'
        fi
        exec herdr --session ${name}-session
      '';
    in
    pkgs.writeShellScriptBin "${name}-sandbox" ''
      if [ "$1" = "-i" ]; then
        exec sudo -u ${user} -i
      fi
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Refreshing workspace ACLs..."
      ${pkgs.acl}/bin/setfacl -R -m g:${group}:rwx ${workspace} 2>/dev/null || true

      echo "🔒 Elevating permissions to switch to '${user}'..."
      exec sudo -u ${user} -i ${inner} "$HOST_DIR"
    '';
in
{
  users.groups.claude_workspace = { };
  users.groups.opencode_workspace = { };

  users.users.opencode = {
    isNormalUser = true;
    description = "Isolated opencode user";
    createHome = true;
    extraGroups = [ "opencode_workspace" ];
    packages = [ pkgs-unstable.opencode ];
  };

  users.users.claude = {
    isNormalUser = true;
    description = "Isolated claude user";
    createHome = true;
    extraGroups = [ "claude_workspace" ];
    packages = [ pkgs-unstable.claude-code ];
  };

  users.users.eox.extraGroups = [
    "claude_workspace"
    "opencode_workspace"
  ];

  # ACL support on the mount holding the workspaces. /var is usually on /,
  # but if /var is a separate partition, add "acl" to that entry instead.
  fileSystems."/".options = [ "acl" ];

  systemd.tmpfiles.rules = [
    "d      /var/opt/opencode-workspace           2770  eox       opencode_workspace  -    -"
    "L+     /home/eox/private/opencode-workspace  -     -         -                   -    /var/opt/opencode-workspace"
    "L+     /home/opencode/workspace              -     -         -                   -    /var/opt/opencode-workspace"
    "d      /home/opencode/.config                0755  opencode  -                   -    -"
    "L+     /home/opencode/.config/starship.toml  -     -         -                   -    ${ai-starship-config}"
    # herdr writes herdr.log and its siblings next to config.toml, so the
    # directory must stay writable even though the config itself is a store symlink.
    "d      /home/opencode/.config/herdr          0755  opencode  -                   -    -"
    "L+     /home/opencode/.config/herdr/config.toml -  -         -                   -    ${eox-herdr-config}"

    "d      /var/opt/claude-workspace             2770  eox       claude_workspace    -    -"
    "L+     /home/eox/work/claude-workspace       -     -         -                   -    /var/opt/claude-workspace"
    "L+     /home/claude/workspace                -     -         -                   -    /var/opt/claude-workspace"
    "d      /home/claude/.config                  0755  claude    -                   -    -"
    "L+     /home/claude/.config/starship.toml    -     -         -                   -    ${ai-starship-config}"
    "d      /home/claude/.config/herdr            0755  claude    -                   -    -"
    "L+     /home/claude/.config/herdr/config.toml   -  -         -                   -    ${eox-herdr-config}"
  ];

  systemd.services.acl-claude-workspace = mkWorkspaceAclService {
    dir = "/var/opt/claude-workspace";
    group = "claude_workspace";
  };

  systemd.services.acl-opencode-workspace = mkWorkspaceAclService {
    dir = "/var/opt/opencode-workspace";
    group = "opencode_workspace";
  };

  # Read-only view of the dotfiles for the claude sandbox, so it can inspect
  # the NixOS and herdr config it is asked to reason about. opencode is
  # deliberately not granted this.
  # claude gets read *and write* on the whole dotfiles tree, so it can edit this
  # config directly instead of handing back patches. Note what that widens: the
  # tree includes zsh/, bin/, and hypr/, all of which execute as eox at login,
  # so this is a larger blast radius than the workspace sandbox alone. Git is
  # the backstop — everything here is version-controlled and revertible.
  systemd.services.acl-claude-dotfiles = mkExternalAclService {
    traverse = traverseAcls.claude_workspace;
    dir = "/home/eox/.dotfiles";
    group = "claude_workspace";
    perms = "rwX";
  };

  # opencode gets a far narrower grant: just enough to read the shared herdr
  # config it is symlinked to, and nothing else in the dotfiles. Traversal stops
  # at .dotfiles, so the rest of the tree stays invisible to it.
  systemd.services.acl-opencode-herdr-config = mkExternalAclService {
    traverse = traverseAcls.opencode_workspace;
    dir = "/home/eox/.dotfiles/herdr";
    group = "opencode_workspace";
  };

  # NixOS's `users` activation snippet chmods every createHome home on every
  # activation (update-users-groups.pl, and eox is homeMode 700). A chmod on an
  # ACL-bearing directory rewrites the ACL mask from the new group bits, so
  # `chmod 0700 /home/eox` leaves mask::--- and every named entry on it reads
  # `#effective:---` — the traverse gates are still listed, but grant nothing.
  #
  # The oneshot units above cannot repair this: they are RemainAfterExit, so
  # switch-to-configuration leaves them alone unless the unit itself changed.
  # The result is a rebuild that silently revokes the sandboxes' access to this
  # tree until the next reboot, which is how herdr lost its config on 2026-08-03.
  #
  # Ordering `after` the users snippet puts this on the correct side of that
  # chmod on every activation. Only the gates need it — nothing chmods the
  # trees themselves, so the recursive grants stay in the boot-time oneshots.
  system.activationScripts.sandboxTraverseAcls = {
    deps = [ "users" ];
    text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        group: paths: "${pkgs.acl}/bin/setfacl -m g:${group}:x ${lib.escapeShellArgs paths} || true"
      ) traverseAcls
    );
  };

  # herdr's Claude Code hook. CLAUDE_CONFIG_DIR is pinned rather than inherited:
  # systemd does not read the user's shell profile, and /home/claude/.zshrc
  # carries a `claude-personal` alias that points CLAUDE_CONFIG_DIR at
  # ~/.claude-personal. Panes launched by herdr run plain `claude`, so ~/.claude
  # is the tree that matters — pinning it keeps the hook and the agent agreeing
  # no matter what the ambient environment says.
  systemd.services.herdr-integration-claude = mkAgentIntegrationService {
    user = "claude";
    agent = "claude";
    configDir = "/home/claude/.claude";
    env.CLAUDE_CONFIG_DIR = "/home/claude/.claude";
  };

  systemd.services.herdr-integration-opencode = mkAgentIntegrationService {
    user = "opencode";
    agent = "opencode";
    configDir = "/home/opencode/.config/opencode";
  };

  environment.systemPackages = [
    pkgs.acl

    (mkSandbox {
      name = "claude";
      user = "claude";
      group = "claude_workspace";
      workspace = "/var/opt/claude-workspace";
    })

    (mkSandbox {
      name = "opencode";
      user = "opencode";
      group = "opencode_workspace";
      workspace = "/var/opt/opencode-workspace";
    })
  ];
}
