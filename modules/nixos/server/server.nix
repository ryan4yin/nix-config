{lib, ...}: {
  imports = [
    ../base
    ../../base.nix
  ];
  boot.loader.timeout = lib.mkForce 7; # wait for x seconds to select the boot entry
}
