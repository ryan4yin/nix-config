# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/hyprland.nix
      ../../modules/fcitx5

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";  #  "nodev"
      efiSupport = false;
      useOSProber = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    };
  };

  networking = {
    hostName = "nixos-test"; # Define your hostname.
    wireless.enable = false;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager.enable = true;
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "192.168.5.48";
        prefixLength = 24;
      } ];
    };
    defaultGateway = "192.168.5.201";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}


