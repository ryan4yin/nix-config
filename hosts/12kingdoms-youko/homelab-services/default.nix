{ mylib, ... }:
{
  # The homelab service modules, migrated here from the retired `aquamarine` VM
  # (the `hosts/idols-aquamarine` path is a physical host now).
  imports = mylib.scanPaths ./.;
}
