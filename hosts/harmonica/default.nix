{ ... } @ args:

#############################################################
#
#  Harmonica - my MacBook Pro 2020 13-inch, mainly for business.
#
#############################################################

let
  name = "harmonica";
in
{
  imports = [
    ../../modules/darwin/core.nix
    ../../modules/darwin/apps.nix

    ../../secrets/darwin.nix
  ];

  nixpkgs.overlays = import ../../overlays args;

  networking.hostName = name;
  networking.computerName = name;
  system.defaults.smb.NetBIOSName = name;
}
