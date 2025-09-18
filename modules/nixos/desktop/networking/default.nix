{ mylib, ... }:
{
  imports = mylib.scanPaths ./.;

  # enable tailscae for all desktop hosts
  services.tailscale.enable = true;
}
