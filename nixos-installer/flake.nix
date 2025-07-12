{
  description = "NixOS configuration of Ryan Yin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    preservation.url = "github:nix-community/preservation";
    nuenv.url = "github:DeterminateSystems/nuenv";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (inputs.nixpkgs) lib;
    mylib = import ../lib {inherit lib;};
    myvars = import ../vars {inherit lib;};
  in {
    nixosConfigurations = {
      ai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs =
          inputs
          // {
            inherit mylib myvars;
          };

        modules = [
          {networking.hostName = "ai";}

          ./configuration.nix

          ../modules/base
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/idols-ai/hardware-configuration.nix
          ../hosts/idols-ai/preservation.nix
        ];
      };

      shoukei = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs =
          inputs
          // {
            inherit mylib myvars;
          };
        modules = [
          {networking.hostName = "shoukei";}

          ./configuration.nix

          ../modules/base
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/12kingdoms-shoukei/hardware-configuration.nix
          ../hosts/idols-ai/preservation.nix
        ];
      };
    };
  };
}
