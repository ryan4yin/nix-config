{ config, lib, ... }:

##############################################################################
#
#  Template for Proxmox's VM, mainly based on:
#    https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/virtualisation/proxmox-image.nix
#
#  the url above is used by `nixos-generator` to generate the Proxmox's VMA image file.
# 
##############################################################################

let
  bios = "seabios";
  partitionTableType = if bios == "seabios" then "legacy" else "efi";
  supportEfi = partitionTableType == "efi" || partitionTableType == "hybrid";
  supportBios = partitionTableType == "legacy" || partitionTableType == "hybrid" || partitionTableType == "legacy+gpt";
  hasBootPartition = partitionTableType == "efi" || partitionTableType == "hybrid";
  hasNoFsPartition = partitionTableType == "hybrid" || partitionTableType == "legacy+gpt";
in
{

  # DO NOT promote ryan to input password for sudo.
  # this is a workaround for the issue of remote deploy:
  #   https://github.com/NixOS/nixpkgs/issues/118655
  security.sudo.extraRules = [
    { users = [ "ryan" ];
      commands = [
        { command = "ALL" ;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  boot = {
    # after resize the disk, it will grow partition automatically.
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
    loader.grub = {
      device = lib.mkDefault (if (hasNoFsPartition || supportBios) then
        # Even if there is a separate no-fs partition ("/dev/disk/by-partlabel/no-fs" i.e. "/dev/vda2"),
        # which will be used the bootloader, do not set it as loader.grub.device.
        # GRUB installation fails, unless the whole disk is selected.
        "/dev/vda"
      else
        "nodev");
      efiSupport = lib.mkDefault supportEfi;
      efiInstallAsRemovable = lib.mkDefault supportEfi;
    };

    loader.timeout = 0;
    initrd.availableKernelModules = [ "uas" "virtio_blk" "virtio_pci" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };
  fileSystems."/boot" = lib.mkIf hasBootPartition {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  # it alse had qemu-guest-agent installed by default.
  services.qemuGuest.enable = lib.mkDefault true;
}
