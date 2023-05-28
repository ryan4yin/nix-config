{config, pkgs, ...}: 
{
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