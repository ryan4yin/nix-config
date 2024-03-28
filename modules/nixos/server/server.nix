{
  imports = [
    ../base
    ../../base.nix
  ];
  boot.loader.timeout = 3; # wait for 3 seconds to select the boot entry
}
