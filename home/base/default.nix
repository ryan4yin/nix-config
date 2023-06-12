{ config, pkgs, ... }:
{
  imports = [
    ./nushell
    ./tmux

    ./bash.nix
    ./core.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./starship.nix
  ];

}
