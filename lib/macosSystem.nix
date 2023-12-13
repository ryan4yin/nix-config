{
  nixpkgs,
  nix-darwin,
  home-manager,
  system,
  specialArgs,
  darwin-modules,
  home-module,
}: let
  username = specialArgs.username;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        ({lib, ...}: {
          # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
          nix.registry.nixpkgs.flake = nixpkgs;

          environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
          # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
          # discard all the default paths, and only use the one from this flake.
          nix.nixPath = lib.mkForce ["/etc/nix/inputs"];
        })

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users."${username}" = home-module;
        }
      ];
  }
