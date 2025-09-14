{ mylib, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./alert.nix
  ];
}
