{ mylib, ... }:
{
  # aquamarine's service modules, moved here from the retired `hosts/idols-aquamarine`
  # guest now that its services run directly on this host.
  imports = mylib.scanPaths ./.;
}
