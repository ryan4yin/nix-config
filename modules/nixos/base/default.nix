{ mylib, ... }:
{
  imports = mylib.scanPaths ./. ++ [ (mylib.relativeToRoot "hardening/apparmor") ];
}
