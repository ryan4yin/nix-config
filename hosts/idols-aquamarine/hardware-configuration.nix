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

  boot.kernelParams = [
    # Carried over from `ai`, where it caps NVMe APST wake latency for the
    # DRAM-less KINGBANK KP260 (WA-008 in WORKAROUNDS.md). This disk (Fanxiang
    # S790) has shown no APST problem; the cap stays as idle-power insurance.
    "nvme_core.default_ps_max_latency_us=100000"
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # The nixpkgs default (`linuxPackages`) is the stable/LTS line, which is what a
  # server should run; `linuxPackages_latest` is for chasing new hardware. The
  # R9700 (Navi 48) only needs the 6.14 AMD validates for it, so the default is
  # far ahead of the requirement. See ./ROCM.md.
  # https://github.com/nixpkgs/nixpkgs/blob/nixos-unstable/pkgs/top-level/linux-kernels.nix
  boot.kernelPackages = pkgs.linuxPackages;

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

  # Enable binfmt emulation of aarch64-linux, this is required for cross compilation.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  # This enables the kernel to preload the emulator binaries when the binfmt registrations are added,
  # obviating the need to make the emulator binaries available inside chroots and chroot-like sandboxes.
  boot.binfmt.preferStaticEmulators = true; # required to work with podman

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
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance"; # ondemand / powersave / performance
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
