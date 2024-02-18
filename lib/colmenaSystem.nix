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
      targetHost = builtins.replaceStrings ["_"] ["-"] name; # hostName or IP address
      tags = host_tags;
    };

    imports =
      nixos-modules
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
