# Hand-adapted from the `nixos-generate-config --show-hardware-config` scan that
# `ai` captured on this same Colorful CVN Z890 ARK FROZEN V20 board, with the
# KINGBANK-specific parts left behind. The
# mounts themselves are declared in ./disko-fs.nix, so nothing here names a
# disk. Regenerate this file on the target (`nixos-generate-config --root /mnt`)
# if the hardware scan ever differs.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Track newer amdgpu/KFD fixes for the R9700 inference containers.
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/top-level/linux-kernels.nix
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  # clear /tmp on boot to get a stateless /tmp directory.
  boot.tmp.cleanOnBoot = true;

  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  # LUKS initrd, all fileSystems (/, /boot, /btr_pool, /nix, /persistent, /snapshots, /tmp, /swap)
  # and swap (including /swap/swapfile bind and swapDevices) are managed by disko (disko-fs.nix).

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode and both the Intel iGPU and AMD GPU firmware.
  hardware.enableRedistributableFirmware = true;
  # Shared graphics stack for the i915 console/video path and the R9700s.
  hardware.graphics.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance"; # ondemand / powersave / performance
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
