{ pkgs, ... }: {

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = false;
  # services.xserver.desktopManager.gnome.enable = false;

  # services.displayManager.sddm = {
  #   enable = true;
  #   theme = "sddm-astronaut-theme";
  #   package = pkgs.kdePackages.sddm;
  #   extraPackages = with pkgs; [
  #     kdePackages.qtsvg
  #     kdePackages.qtmultimedia
  #     kdePackages.qtvirtualkeyboard
  #     kdePackages.qt5compat
  #   ];
  # };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --greeting 'The journey begins with a single login. Make it count.' \
          --time \
          --remember \
          --asterisks \
          --cmd 'hyprland'
        '';
        user = "greeter";
      };
    };
  };

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.thunar.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    cliphist
    dunst
    grim
    hypridle
    hyprpaper
    hyprpolkitagent
    libnotify
    pavucontrol
    rofi-wayland
    # sddm-astronaut
    slurp
    waybar
    wl-clipboard
    xclip
  ];
  # Install font
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  # fonts.packages = with pkgs;
  #   [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
}
