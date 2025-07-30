{ mylib, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./alertmanager.nix
  ];
}
