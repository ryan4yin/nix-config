{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [],
  myvars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  inherit (inputs) nixpkgs home-manager nix-darwin;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs {inherit system;};
        })
      ]
      ++ (
        lib.optionals ((lib.lists.length home-modules) > 0)
        [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${myvars.username}".imports = home-modules;
          }
        ]
      );
  }
