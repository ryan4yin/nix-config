# colmena - Remote Deployment via SSH
{
  inputs,
  nixos-modules,
  home-module ? null,
  myvars,
  system,
  tags,
  ssh-user,
  genSpecialArgs,
  ...
}: let
  inherit (inputs) home-manager;
  specialArgs = genSpecialArgs system;
in
  {name, ...}: {
    deployment = {
      inherit tags;
      targetUser = ssh-user;
      targetHost = name; # hostName or IP address
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
            home-manager.users."${myvars.username}" = home-module;
          }
        ]
        else []
      );
  }
