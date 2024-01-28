{
  pkgs,
  nixos-hardware,
  ...
} @ args:
#############################################################
#
#  Shoukei - NixOS running on Macbook Pro 2020 I5 16G
#   https://github.com/NixOS/nixos-hardware/tree/master/apple/t2
#
#############################################################
{
  imports = [
    nixos-hardware.nixosModules.apple-t2
    ./apple-set-os-loader.nix
    {hardware.myapple-t2.enableAppleSetOsLoader = true;}

    ./hardware-configuration.nix
    ./impermanence.nix
  ];

  boot.kernelModules = ["kvm-amd" "kvm-intel"];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu

  networking = {
    hostName = "shoukei"; # Define your hostname.
    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  system.stateVersion = "23.11"; # Did you read the comment?
}
