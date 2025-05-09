{ pkgs, ... }: {

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
    # Applications
    brave
    discord
    ghostty
    google-chrome
    jetbrains.idea-ultimate
    qemu
    quickemu
    teams-for-linux
    yazi

    # Devtools
    clang
    dart-sass
    gh
    git
    gnumake
    go
    jdk21
    lazygit
    leptosfmt
    libclang
    nixd
    nodejs_23
    podman-compose
    python3
    quarkus
    rust-analyzer
    rustup
    tailwindcss
    typescript

    # Utils
    bat
    btop
    curl
    fzf
    httpie
    neofetch
    ripgrep
    sshs
    starship
    stow
    tldr
    unzip
    wget
  ];
}
