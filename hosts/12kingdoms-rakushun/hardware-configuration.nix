{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader = {
    # depending on how you configured your disk mounts, change this to /boot or /boot/efi.
    efi.efiSysMountPoint = "/boot/";
    efi.canTouchEfiVariables = true;
    # do not use systemd-boot here, it has problems when running `nixos-install`
    grub = {
      device = "nodev";
      efiSupport = true;
    };
  };
  # clear /tmp on boot to get a stateless /tmp directory.
  boot.tmp.cleanOnBoot = true;

  boot.initrd.availableKernelModules = ["nvme" "usbhid" "usb_storage"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enP3p49s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enP4p65s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
