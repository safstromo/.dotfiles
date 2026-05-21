{ config, pkgs, pkgs-unstable, ... }: {

  # Dedicated groups for the shared workspaces
  users.groups.claude_workspace = { };
  users.groups.opencode_workspace = { };

  # Define the isolated AI users
  users.users.opencode = {
    isNormalUser = true;
    description = "Isolated opencode user";
    createHome = true;
    linger = true;
    extraGroups = [ "opencode_workspace" ];
    packages = [ pkgs-unstable.opencode ];
  };

  users.users.claude = {
    isNormalUser = true;
    description = "Isolated claude user";
    createHome = true;
    linger = true;
    extraGroups = [ "claude_workspace" ];
    packages = [ pkgs-unstable.claude-code ];
  };

  # Add main user to the shared workspace groups
  users.users.eox.extraGroups = [ "claude_workspace" "opencode_workspace" ];

  # Create the directories and symlinks
  systemd.tmpfiles.rules = [
    # Type  Path                                  Mode  User  Group               Age  Target
    "d      /var/opt/opencode-workspace           2770  eox   opencode_workspace  -    -"
    "L+     /home/eox/personal/opencode-workspace  -     -     -                   -    /var/opt/opencode-workspace"
    "L+     /home/opencode/workspace              -     -     -                   -    /var/opt/opencode-workspace"

    "d      /var/opt/claude-workspace             2770  eox   claude_workspace    -    -"
    "L+     /home/eox/work/claude-workspace       -     -     -                   -    /var/opt/claude-workspace"
    "L+     /home/claude/workspace                -     -     -                   -    /var/opt/claude-workspace"
  ];

  # Create the launcher scripts globally
  environment.systemPackages = [

    (pkgs.writeShellScriptBin "claude-sandbox" ''
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Elevating permissions to switch to 'claude'..."

      # Try changing to the host dir. If it fails, fallback to the shared workspace.
      sudo -u claude -i zsh -i -c "if ! cd '$HOST_DIR' 2>/dev/null; then echo '⚠️  No access to current directory. Dropping into default workspace...'; cd '/var/opt/claude-workspace'; fi; claude"
    '')

    (pkgs.writeShellScriptBin "opencode-sandbox" ''
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Elevating permissions to switch to 'opencode'..."

      # Try changing to the host dir. If it fails, fallback to the shared workspace.
      sudo -u opencode -i zsh -i -c "if ! cd '$HOST_DIR' 2>/dev/null; then echo '⚠️  No access to current directory. Dropping into default workspace...'; cd '/var/opt/opencode-workspace'; fi; opencode"
    '')

  ];
}
