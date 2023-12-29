# colmena - Remote Deployment via SSH
{
  nixpkgs,
  home-manager,
  specialArgs,
  nixos-modules,
  home-module ? null,
  host_tags,
  targetUser ? specialArgs.username,
}: let
  inherit (specialArgs) username;
in
  {name, ...}: {
    deployment = {
      inherit targetUser;
      targetHost = name; # hostName or IP address
      tags = host_tags;
    };

    imports =
      nixos-modules
      ++ [
        {
          # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
          nix.registry.nixpkgs.flake = nixpkgs;
          nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
          
          # but NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
          # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
          environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
          nix.settings.nix-path = nixpkgs.lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
          environment.sessionVariables.NIX_PATH = nixpkgs.lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
        }
      ]
      ++ (
        if (home-module != null)
        then [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${username}" = home-module;
          }
        ]
        else []
      );
  }
