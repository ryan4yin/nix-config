{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [ ],
  myvars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}:
let
  inherit (inputs) nixpkgs-darwin home-manager nix-darwin;
in
nix-darwin.lib.darwinSystem {
  inherit system specialArgs;
  modules =
    darwin-modules
    ++ [
      {
        nixpkgs.pkgs = import nixpkgs-darwin {
          inherit system; # refer the `system` parameter form outer scope recursively
          # `nixpkgs.config` is ignored once `nixpkgs.pkgs` is set.
          config = specialArgs.nixpkgsConfig;
        };
      }
    ]
    ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "home-manager.backup";

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users."${myvars.username}".imports = home-modules;
      }
    ]);
}
