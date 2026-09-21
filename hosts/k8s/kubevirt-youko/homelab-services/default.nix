{ mylib, ... }:
{
  # The homelab service modules, migrated here from the retired
  # `hosts/idols-aquamarine` guest, now running directly on this host.
  imports = mylib.scanPaths ./.;
}
