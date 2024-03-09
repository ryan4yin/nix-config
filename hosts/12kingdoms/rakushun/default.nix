{
  disko,
  nixos-rk3588,
  vars_networking,
  ...
}:
#############################################################
#
#  Suzu - Orange Pi 5 Plus, RK3588 + 16GB RAM
#
#############################################################
let
  hostName = "rakushun"; # Define your hostname.
  hostAddress = vars_networking.hostAddress.${hostName};
in {
  imports = [
    # import the rk3588 module, which contains the configuration for bootloader/kernel/firmware
    nixos-rk3588.nixosModules.orangepi5plus.core
    disko.nixosModules.default
    ./hardware-configuration.nix
    ./disko-fs.nix
    ./impermanence.nix
  ];

  networking = {
    inherit hostName;
    inherit (vars_networking) defaultGateway nameservers;

    networkmanager.enable = false;
    # RJ45 port 1
    interfaces.enP4p65s0 = {
      useDHCP = false;
      ipv4.addresses = [hostAddress];
    };
    # RJ45 port 2
    # interfaces.enP3p49s0 = {
    # useDHCP = false;
    # ipv4.addresses = [hostAddress];
    # };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
