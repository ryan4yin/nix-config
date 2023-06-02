{config, pkgs, ...}: 
{
  imports = [
    ./nushell

    ./core.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./starship.nix
  ];

}