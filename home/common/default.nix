{config, pkgs, ...}: 
{
  imports = [
    ./nushell

    ./alacritty
    ./core.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./starship.nix
  ];

}