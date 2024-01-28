{nixos-rk3588, ...}:
#############################################################
#
#  Suzu - Orange Pi 5, RK3588s
#
#############################################################
let
  hostName = "suzu"; # Define your hostname.
  vars = import ../vars.nix;
  hostAddress = vars.networking.hostAddress.${hostName};
in {
  imports = [
    # import the rk3588 module, which contains the configuration for bootloader/kernel/firmware
    nixos-rk3588.nixosModules.orangepi5
  ];

  networking = {
    inherit hostName;
    inherit (vars.networking) defaultGateway nameservers;

    networkmanager.enable = false;
    interfaces.end1 = {
      useDHCP = false;
      ipv4.addresses = [hostAddress];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
