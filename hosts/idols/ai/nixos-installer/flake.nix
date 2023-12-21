{
  description = "NixOS configuration of Ryan Yin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations = {
      ai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./configuration.nix
          ./system.nix

          ../hardware-configuration.nix
          ../impermanence.nix
        ];
      };
    };
  };
}
