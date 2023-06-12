{config, pkgs, ...}: 
{
  imports = [
    ./nushell
    ./bash.nix

    ./core.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./starship.nix
  ];

}