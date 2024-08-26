{
  mylib,
  lib,
  ...
}: {
  imports = mylib.scanPaths ./.;

  boot.loader.timeout = lib.mkForce 10; # wait for x seconds to select the boot entry
}
