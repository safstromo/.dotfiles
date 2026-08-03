{ config, pkgs, pkgs-unstable, ... }:
let
  ai-starship-config = pkgs.writeText "starship.toml" ''
    [username]
    show_always = true
    style_user = "bold purple"
    format = '[$user]($style)'
  '';

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

  # One-shot service that grants a group read-only access to a tree *outside*
  # the shared workspaces, so a sandboxed agent can read config it is asked to
  # work on. Deliberately rX, not rwx: read plus directory traversal, never
  # write. Capital X applies execute to directories only, so regular files stay
  # r-- rather than becoming executable.
  mkReadOnlyAclService = { home, dir, group }: {
    description = "Grant ${group} read-only ACLs on ${dir}";
    after = [ "systemd-tmpfiles-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Don't abort the whole service if a single file can't take an ACL.
      set +e

      # Traverse-only (x, no r) on the home dir: the group can walk *through*
      # it to reach ${dir}, but cannot list what else lives there.
      ${pkgs.acl}/bin/setfacl -m g:${group}:x ${home}

      # Read + traverse on the tree, plus a default ACL so files added later
      # inherit it. setfacl -R does not follow symlinks, which matters here
      # because this tree is stow-managed and full of them.
      ${pkgs.acl}/bin/setfacl -R -m  g:${group}:rX ${dir}
      ${pkgs.acl}/bin/setfacl -R -m d:g:${group}:rX ${dir}

      # Always succeed — ACLs are best-effort, and the default ACL on the root
      # is what keeps things working going forward.
      exit 0
    '';
  };

  # Shared launcher logic. Per-user devenv state is the crux of the fix:
  # PostgreSQL (and ssh/gpg) need a 0700 dir they own, which is impossible
  # inside a group-shared tree, so we redirect devenv state into $HOME.
  mkSandbox = { name, user, group, workspace }:
    pkgs.writeShellScriptBin "${name}-sandbox" ''
      if [ "$1" = "-i" ]; then
        exec sudo -u ${user} -i
      fi
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Refreshing workspace ACLs..."
      ${pkgs.acl}/bin/setfacl -R -m g:${group}:rwx ${workspace} 2>/dev/null || true

      echo "🔒 Elevating permissions to switch to '${user}'..."
      sudo -u ${user} -i zsh -i -c "
        umask 002
        if ! cd '$HOST_DIR' 2>/dev/null; then
          echo '⚠️  No access to current directory. Dropping into default workspace...';
          cd '${workspace}';
        fi;
        tmux new-session -A -s ${name}-session '${name}'"
    '';
in {
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

  users.users.eox.extraGroups = [ "claude_workspace" "opencode_workspace" ];

  # ACL support on the mount holding the workspaces. /var is usually on /,
  # but if /var is a separate partition, add "acl" to that entry instead.
  fileSystems."/".options = [ "acl" ];

  systemd.tmpfiles.rules = [
    "d      /var/opt/opencode-workspace           2770  eox       opencode_workspace  -    -"
    "L+     /home/eox/private/opencode-workspace  -     -         -                   -    /var/opt/opencode-workspace"
    "L+     /home/opencode/workspace              -     -         -                   -    /var/opt/opencode-workspace"
    "d      /home/opencode/.config                0755  opencode  -                   -    -"
    "L+     /home/opencode/.config/starship.toml  -     -         -                   -    ${ai-starship-config}"

    "d      /var/opt/claude-workspace             2770  eox       claude_workspace    -    -"
    "L+     /home/eox/work/claude-workspace       -     -         -                   -    /var/opt/claude-workspace"
    "L+     /home/claude/workspace                -     -         -                   -    /var/opt/claude-workspace"
    "d      /home/claude/.config                  0755  claude    -                   -    -"
    "L+     /home/claude/.config/starship.toml    -     -         -                   -    ${ai-starship-config}"
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
  systemd.services.acl-claude-dotfiles = mkReadOnlyAclService {
    home = "/home/eox";
    dir = "/home/eox/.dotfiles";
    group = "claude_workspace";
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
