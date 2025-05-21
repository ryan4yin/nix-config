{
  lib,
  mylib,
  myvars,
  pkgs,
  disko,
  ...
}:
#############################################################
#
#  Aquamarine - A NixOS VM running on Proxmox/KubeVirt
#
#############################################################
let
  hostName = "aquamarine"; # Define your hostname.
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      disko.nixosModules.default
    ];

  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  # Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).
  # Defaults to 1/2 of your total RAM. Run zramctl to check how good memory is compressed.
  # This doesn’t define how much memory will be used by the zram swap devices.
  zramSwap.memoryPercent = lib.mkForce 100;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = ["kvm-amd"];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu

  networking = {
    inherit hostName;
    inherit (myvars.networking) defaultGateway nameservers;
    inherit (myvars.networking.hostsInterface.${hostName}) interfaces;
    networkmanager.enable = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
