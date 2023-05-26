{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./git.nix
    ./media.nix
    ./xdg.nix
  ];
}