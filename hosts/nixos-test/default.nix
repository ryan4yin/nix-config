# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, home-manager, nur, ... } @args:

{
  imports = [
    # This adds a nur configuration option.
    # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
    nur.nixosModules.nur

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/nixos/fhs-fonts.nix
    ../../modules/nixos/hyprland.nix
    # ../../modules/nixos/i3.nix
    ../../modules/nixos/gui-apps.nix
    ../../modules/nixos/core-desktop.nix
    ../../modules/nixos/user_group.nix
  ];

  nixpkgs.overlays = import ../../overlays args;


  # Enable binfmt emulation of aarch64-linux, this is required for cross compilation.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # supported fil systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
    "cifs" # mount windows share
  ];

  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda"; #  "nodev"
      efiSupport = false;
      useOSProber = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    };
  };

  networking = {
    hostName = "nixos-test"; # Define your hostname.
    wireless.enable = false; # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager.enable = true;
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.5.48";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.5.201";
    nameservers = [
      "119.29.29.29" # DNSPod
      "223.5.5.5" # AliDNS
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
