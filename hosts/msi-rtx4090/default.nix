# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, home-manager, nur, ... } @ args:

{
  imports = [
    # This adds a nur configuration option.
    # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
    nur.nixosModules.nur

    ./cifs-mount.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/fhs-fonts.nix
    ../../modules/hyprland.nix
    #../../modules/i3.nix
    ../../modules/nur-packages.nix
    ../../modules/system.nix
    ../../modules/user_group.nix

    ../../secrets
  ];

  nixpkgs.overlays = import ../../overlays args;

  # Enable binfmt emulation of aarch64-linux, this is required for cross compilation.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "msi-rtx4090"; # Define your hostname.
    wireless.enable = false;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager.enable = true;

    enableIPv6 = false;  # disable ipv6
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "192.168.5.66";
        prefixLength = 24;
      } ];
    };
    defaultGateway = "192.168.5.201";
    nameservers = [
      "119.29.29.29"  # DNSPod
      "223.5.5.5"     # AliDNS
    ];
  };


  # for Nvidia GPU

  services.xserver.videoDrivers = ["nvidia"];  # will install nvidia-vaapi-driver by default
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  hardware.opengl = {
    enable = true;
    # if hardware.opengl.driSupport is enabled, mesa is installed and provides Vulkan for supported hardware. 
    driSupport = true;
    # needed by nvidia-docker
    driSupport32Bit = true;
  };

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    storageDriver = "btrfs";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}


