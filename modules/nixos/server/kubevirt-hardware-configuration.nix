{
  modulesPath,
  lib,
  ...
}:
##############################################################################
#
#  Template for KubeVirt's VM, mainly based on:
#    https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/kubevirt.nix
#
#  We write our hardware-configuration.nix, so that we can do some customization more easily.
#
#  the url above is used by `nixos-generator` to generate the KubeVirt's qcow2 image file.
#
##############################################################################
{
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    boot.growPartition = true;
    boot.kernelParams = ["console=ttyS0"];
    boot.loader.grub.device = "/dev/vda";

    services.qemuGuest.enable = true;
    services.openssh.enable = true;
    # we configure the host via nixos itself, so we don't need the cloud-init
    services.cloud-init.enable = lib.mkForce false;
    systemd.services."serial-getty@ttyS0".enable = true;
  };
}
