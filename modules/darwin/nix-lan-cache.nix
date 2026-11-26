{ lib, ... }:
{
  # macOS hosts are laptops that leave the home network.
  modules.nix.lanCache.enable = lib.mkDefault false;
}
