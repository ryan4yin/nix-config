{mylib, ...}: {
  imports = [
    ./module
    ./victoriametrics.nix
    ./alertmanager.nix
  ];
}
