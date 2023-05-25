{ config, pkgs, home-manager, ... } @ args:

{
  imports = [
    ../../modules/fhs-fonts.nix
    ../../modules/system.nix
  ];
}


