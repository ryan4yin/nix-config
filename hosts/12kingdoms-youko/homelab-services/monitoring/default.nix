{ mylib, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./alert.nix
    ./blackbox.nix
  ];
}
