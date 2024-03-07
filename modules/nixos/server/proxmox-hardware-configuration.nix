{lib, ...}:
##############################################################################
#
#  Template for Proxmox's VM, mainly based on:
#    https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/virtualisation/proxmox-image.nix
#
#  the url above is used by `nixos-generator` to generate the Proxmox's VMA image file.
#
##############################################################################
{
  boot = {
    # after resize the disk, it will grow partition automatically.
    growPartition = true;
    kernelParams = ["console=ttyS0"];
    loader.grub = {
      device = "/dev/vda";

      # we do not support EFI, so disable it.
      efiSupport = false;
      efiInstallAsRemovable = false;
    };

    loader.timeout = lib.mkForce 3; # wait for 3 seconds to select the boot entry
    initrd.availableKernelModules = ["uas" "virtio_blk" "virtio_pci"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };
  # we do not have a /boot partition, so do not mount it.

  # it alse had qemu-guest-agent installed by default.
  services.qemuGuest.enable = lib.mkDefault true;
}
