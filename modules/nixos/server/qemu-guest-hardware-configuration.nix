{
  lib,
  ...
}:
{
  imports = [
    ./qemu-guest.nix
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };
  };
}
