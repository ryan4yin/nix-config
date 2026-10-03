{ mylib, ... }:
{
  imports = mylib.scanPaths ./. ++ [
    (mylib.relativeToRoot "hardening/apparmor")
    (mylib.relativeToRoot "hardening/kernel-hardening.nix")
  ];
}
