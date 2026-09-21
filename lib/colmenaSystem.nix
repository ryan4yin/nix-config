# colmena - Remote Deployment via SSH
{
  lib,
  inputs,
  nixos-modules,
  home-modules ? [ ],
  myvars,
  system,
  tags,
  ssh-user,
  # optional override; defaults to the host name. Use an IP when the host's
  # DNS name is not resolvable yet (e.g. right after a hostname change).
  targetHost ? null,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}:
let
  inherit (inputs) home-manager;
in
{ name, ... }:
{
  deployment = {
    inherit tags;
    targetUser = ssh-user;
    targetHost = if targetHost != null then targetHost else name;
  };

  imports =
    nixos-modules
    ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "home-manager.backup";

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users."${myvars.username}".imports = home-modules;
      }
    ]);
}
