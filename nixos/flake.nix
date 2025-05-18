{
  description = "Eox NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {

    nixosConfigurations.nixlap = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./desktop-env.nix
        ./packages.nix
        disko.nixosModules.disko
        {
          disko.devices = {
            disk = {
              main = {
                type = "disk";
                device = "/dev/sda";
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      size = "512M";
                      type = "EF00";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        mountOptions = [ "umask=0077" ];
                      };
                    };
                    luks = {
                      size = "100%";
                      content = {
                        type = "luks";
                        name = "crypted";
                        # disable settings.keyFile if you want to use interactive password entry
                        #passwordFile = "/tmp/secret.key"; # Interactive
                        settings = {
                          allowDiscards = true;
                          # keyFile = "/tmp/secret.key";
                        };
                        # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                        content = {
                          type = "btrfs";
                          extraArgs = [ "-f" ];
                          subvolumes = {
                            "/root" = {
                              mountpoint = "/";
                              mountOptions = [ "compress=zstd" "noatime" ];
                            };
                            "/home" = {
                              mountpoint = "/home";
                              mountOptions = [ "compress=zstd" "noatime" ];
                            };
                            "/nix" = {
                              mountpoint = "/nix";
                              mountOptions = [ "compress=zstd" "noatime" ];
                            };
                            "/swap" = {
                              mountpoint = "/.swapvol";
                              swap.swapfile.size = "20M";
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        }
      ];
    };
  };
}
