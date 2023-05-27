{config, pkgs, ...}: let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in rec {
  imports = [
    ./nushell

    ./alacritty.nix
    ./core.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./starship.nix
  ];

}