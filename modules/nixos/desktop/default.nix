{ mylib, ... }:
{
  imports = mylib.scanPaths ./. ++ [ ../power.nix ];
  services.upower.enable = true;
}
