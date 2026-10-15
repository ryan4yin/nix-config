{ mylib, ... }:
{
  imports = mylib.scanPaths ./. ++ [ ../power.nix ];
}
