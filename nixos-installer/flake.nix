{
  description = "NixOS configuration of Ryan Yin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    impermanence.url = "github:nix-community/impermanence";
    nuenv.url = "github:DeterminateSystems/nuenv";
  };

  outputs = inputs @ {
    nixpkgs,
    nuenv,
    ...
  }: {
    nixosConfigurations = {
      ai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs =
          inputs
          // {
            myvars.username = "ryan";
            myvars.userfullname = "Ryan Yin";
          };
        modules = [
          {networking.hostName = "ai";}

          ./configuration.nix

          ../modules/base
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/idols-ai/hardware-configuration.nix
          ../hosts/idols-ai/impermanence.nix
        ];
      };

      shoukei = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs =
          inputs
          // {
            myvars.username = "ryan";
            myvars.userfullname = "Ryan Yin";
          };
        modules = [
          ({pkgs, ...}: {
            networking.hostName = "shoukei";
            boot.kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel for the initial installation.
          })

          ./configuration.nix

          ../modules/base
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/12kingdoms-shoukei/hardware-configuration.nix
          ../hosts/idols-ai/impermanence.nix
        ];
      };
    };
  };
}
