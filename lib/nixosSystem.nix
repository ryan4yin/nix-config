{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-module ? null,
  myvars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager nixos-generators;
  specialArgs = genSpecialArgs system;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ [
        nixos-generators.nixosModules.all-formats
        {
          # formatConfigs.iso = {config, ...}: {};
          formatConfigs.proxmox = {config, ...}: {
            # custom proxmox's image name
            proxmox.qemuConf.name = "${config.networking.hostName}-nixos-${config.system.nixos.label}";
          };
        }
      ]
      ++ (
        lib.optionals (home-module != null)
        [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${myvars.username}" = home-module;
          }
        ]
      );
  }
