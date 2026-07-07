# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.initrd.luks.devices."luks-1bc89d9b-f403-4bf4-9ac7-cec1d53d3a94".device =
    "/dev/disk/by-uuid/1bc89d9b-f403-4bf4-9ac7-cec1d53d3a94";

  networking.hostName = "olsa"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable systemd-resolved to catch DNS changes from IWD
  # services.resolved.enable = true;
  # --- MAC Randomization ---
  # networking.wireless.iwd.settings = {
  #   General = { AddressRandomization = "network"; };
  # };

  services.tailscale.enable = true;

  services.upower.enable = true;
  services.fwupd.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  # powers up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Add disk utils
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Pass yubikey to vm-----------------------------
  # This allows the hardware to be accessed for redirection without remounting /dev
  services.udev.extraRules = ''
    # YubiKey 5 (FIDO2/HMAC support)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", TAG+="uaccess"
  '';
  # Enable Smartcard daemon (Required for Yubikey GPG/PIV/Auth modes)
  services.pcscd.enable = true;
  # --------------------
  # User account
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eox = {
    isNormalUser = true;
    description = "eox";
    extraGroups =
      [ "networkmanager" "wheel" "podman" "libvirtd" "plugdev" "kvm" ];
  };

  # For devenv cachix
  nix.settings.trusted-users = [ "root" "eox" ];

  # Virtualisation stack (libvirt + spice + podman + containers)
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
      qemu.swtpm.enable = true;
    };

    # Enable vm usb passthrough
    spiceUSBRedirection.enable = true;

    # Enable common container config files in /etc/containers
    containers.enable = true;

    podman = {
      enable = true;
      # Create a docker alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.spice-webdavd.enable = true;
  # Point dockerstuff to podman
  # 1. Set static session variables (Crucial for Testcontainers + Podman)
  environment.sessionVariables = { TESTCONTAINERS_RYUK_DISABLED = "true"; };

  # 2. Dynamically evaluate the DOCKER_HOST path for the logged-in user
  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" ]; then
      export DOCKER_HOST="unix://''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
    fi
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  networking.extraHosts = ''
    16.170.99.234 ldapadmin.olsa.test.wizepass.com
    51.20.45.254 ip-172-31-0-198.eu-north-1.compute.internal
  '';
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable fingerprint reader
  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Using nh instead
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7";
  # };
}
