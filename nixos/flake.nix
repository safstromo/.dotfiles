{
  description = "Eox NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, catppuccin, home-manager, ... }@inputs: {

    nixosConfigurations.e00x = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ./configs/e00x/configuration.nix ./desktop-env.nix ./packages.nix ];
    };

    nixosConfigurations.work = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configs/work/configuration.nix
        ./desktop-env.nix
        ./packages.nix

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
