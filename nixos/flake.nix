{
  description = "Eox NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database.url = "github:nix-community/nix-index-database";
    catppuccin.url = "github:catppuccin/nix/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, catppuccin, home-manager
    , nix-index-database, ... }@inputs: {

      nixosConfigurations.e00x = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; };
        };
        modules =
          [ ./configs/e00x/configuration.nix ./desktop-env.nix ./packages.nix ];
      };

      nixosConfigurations.work = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./configs/work/configuration.nix
          ./desktop-env.nix
          ./packages.nix
          ./ai-sandbox.nix

          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }

          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.eox = {
              imports = [ ./home.nix catppuccin.homeModules.catppuccin ];
            };
          }

        ];

      };
    };
}
