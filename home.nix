{ config, pkgs, ... }:
let
  myAliases = {
    ll = "ls -l";
    vi = "nvim";
    vim = "nvim";	
    v = "nvim";
    sv = "sudo nvim";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "eox";
  home.homeDirectory = "/home/eox";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [

   unzip
   neofetch
   ripgrep
   fzf
   
   usbutils
   pciutils
   hyprpaper
   rofi


    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.file.".config/alacritty/" = {

    source = ./alacritty/.config/alacritty;
    recursive = true;
  };

  home.file.".config/nvim/" = {

    source = ./nvim/.config/nvim;
    recursive = true;
  };

  home.file.".config/tmux/" = {

    source = ./tmux/.config/tmux;
    recursive = true;
  };

  home.file.".config/hypr/" = {

    source = ./hypr/.config/hypr;
    recursive = true;
  };


  home.file.".config/rofi/config.rasi".text = ''
    @theme "/dev/null"

    * {
      bg: #000000;
      background-color: @bg;
    }

    configuration {
      modi:		    "run,filebrowser,drun";
      show-icons:	    true;
      icon-theme:	    "Papirus";
      location:		    0;
      font:		    "JetBrains Nerd Font 16";	
      drun-display-format:  "{icon} {name}";
      display-drun:	    "   Apps ";
      display-run:	    "   Run ";
      display-filebrowser:  "   File ";
    }

    window { 
      width: 45%;
      transparency: "real";
      orientation: vertical;
      border: 2px ;
      border-color: #A0427A;
      border-radius: 10px;
    }

    mainbox {
      children: [ inputbar, listview, mode-switcher ];
    }

    // ELEMENT
    // -----------------------------------

    element {
      padding: 8 14;
      text-color: #FEFEFE;
      border-radius: 5px;
    }

    element selected {
      text-color: #FEFEFE;
      background-color: #000000;
    }

    element-text {
      background-color: inherit;
      text-color: inherit;
    }

    element-icon {
      size: 24 px;
      background-color: inherit;
      padding: 0 6 0 0;
      alignment: vertical;
    }

    listview {
      columns: 2;
      lines: 9;
      padding: 8 0;
      fixed-height: true;
      fixed-columns: true;
      fixed-lines: true;
      border: 0 10 6 10;
    }

    // INPUT BAR 
    //------------------------------------------------

    entry {
      text-color: #FEFEFE;
      padding: 10 10 0 0;
      margin: 0 -2 0 0;
    }

    inputbar {
      background-image: url("~/.config/rofi/rofi.jpg", width);
      padding: 180 0 0;
      margin: 0 0 0 0;
    } 

    prompt {
      background-color: #000000;
      padding: 10 6 0 10;
      margin: 0 -2 0 0;
    }

    // Mode Switcher
    //------------------------------------------------

    mode-switcher {
      border-color:   #A04242;
      spacing:	      0;
    }

    button {
      padding:	      10px;
      background-color: @bg;
      text-color: #FEFEFE;
      vertical-align:   0.5; 
      horizontal-align: 0.5;
    }

    button selected {
      background-color: @bg;
      text-color: #FEFEFE;
    }

    message {
      background-color: @bg;
      margin: 2px;
      padding: 2px;
      border-radius: 5px;
    }

    textbox {
      padding: 6px;
      margin: 20px 0px 0px 20px;
      text-color: #FEFEFE;
      background-color: @bg;
    }
  '';


  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/eox/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  

  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "z" ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Oliver Säfström";
    userEmail = "safstrom.oliver@gmail.com";
  };

  programs.starship = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.waybar.enable = true;

  programs.rofi = {
    enable = true;

  };

  # wayland.windowManager.hyprland = {
  #   # Whether to enable Hyprland wayland compositor
  #   enable = true;
  # };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
