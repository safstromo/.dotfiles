{
  description = "Eox NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {

    nixosConfigurations.e00x = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ./configs/e00x/configuration.nix ./desktop-env.nix ./packages.nix ];
    };

    nixosConfigurations.work = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ./configs/work/configuration.nix ./desktop-env.nix ./packages.nix ];
    };
  };
}
