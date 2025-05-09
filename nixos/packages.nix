{ pkgs }: {

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.catppuccin
      tmuxPlugins.yank
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # I use zsh btw
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "z" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sddm-astronaut
    stow
    neofetch
    ghostty
    starship
    wget
    teams-for-linux
    curl
    fzf
    libnotify
    ripgrep
    git
    lazygit
    gh
    dunst
    yazi
    btop
    libclang
    clang
    sshs
    python3
    bat
    unzip
    nodejs_23
    tailwindcss
    rustup
    rust-analyzer
    leptosfmt
    go
    jdk21
    quarkus
    jetbrains.idea-ultimate
    httpie
    google-chrome
    brave
    waybar
    discord
    qemu
    gnumake
    quickemu
    hyprpolkitagent
    hyprpaper
    hypridle
    rofi-wayland
    cliphist
    wl-clipboard
    xclip
    typescript
    nixd
    pavucontrol
    brightnessctl
    tldr
    podman-compose
    slurp
    grim
  ];

}
