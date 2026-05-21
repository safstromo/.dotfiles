{ config, pkgs, pkgs-unstable, ... }:
let
  # Generate a custom Starship configuration for the AI users
  ai-starship-config = pkgs.writeText "starship.toml" ''
    [username]
    show_always = true
    style_user = "bold purple"
    format = '[$user]($style)'
  '';
in {

  # Dedicated groups for the shared workspaces
  users.groups.claude_workspace = { };
  users.groups.opencode_workspace = { };

  # Define the isolated AI users
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

  # Add main user to the shared workspace groups
  users.users.eox.extraGroups = [ "claude_workspace" "opencode_workspace" ];

  # Create the directories and symlinks
  systemd.tmpfiles.rules = [
    # --- OpenCode Workspace & Configs ---
    "d      /var/opt/opencode-workspace           2770  eox       opencode_workspace  -    -"
    "L+     /home/eox/private/opencode-workspace  -     -         -                   -    /var/opt/opencode-workspace"
    "L+     /home/opencode/workspace              -     -         -                   -    /var/opt/opencode-workspace"
    "d      /home/opencode/.config                0755  opencode  -                   -    -"
    "L+     /home/opencode/.config/starship.toml  -     -         -                   -    ${ai-starship-config}"

    # --- Claude Workspace & Configs ---
    "d      /var/opt/claude-workspace             2770  eox       claude_workspace    -    -"
    "L+     /home/eox/work/claude-workspace       -     -         -                   -    /var/opt/claude-workspace"
    "L+     /home/claude/workspace                -     -         -                   -    /var/opt/claude-workspace"
    "d      /home/claude/.config                  0755  claude    -                   -    -"
    "L+     /home/claude/.config/starship.toml    -     -         -                   -    ${ai-starship-config}"
  ];
  # Create the launcher scripts globally
  environment.systemPackages = [

    (pkgs.writeShellScriptBin "claude-sandbox" ''
      if [ "$1" = "-i" ]; then
        exec sudo -u claude -i
      fi
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Elevating permissions to switch to 'claude'..."
      sudo -u claude -i zsh -i -c "
        if ! cd '$HOST_DIR' 2>/dev/null; then 
          echo '⚠️  No access to current directory. Dropping into default workspace...'; 
          cd '/var/opt/claude-workspace'; 
        fi; 
        tmux new-session -A -s claude-session 'claude'"
    '')
    (pkgs.writeShellScriptBin "opencode-sandbox" ''
      if [ "$1" = "-i" ]; then
        exec sudo -u opencode -i
      fi
      HOST_DIR=$(realpath "$PWD")
      echo "🔒 Elevating permissions to switch to 'opencode'..."
      sudo -u opencode -i zsh -i -c "
        if ! cd '$HOST_DIR' 2>/dev/null; then 
          echo '⚠️  No access to current directory. Dropping into default workspace...'; 
          cd '/var/opt/opencode-workspace'; 
        fi; 
        tmux new-session -A -s opencode-session 'opencode'"
    '')
  ];
}
