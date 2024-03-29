{
  mylib,
  disko,
  nixos-rk3588,
  myvars,
  ...
}:
#############################################################
#
#  Suzu - Orange Pi 5 Plus, RK3588 + 16GB RAM
#
#############################################################
let
  hostName = "rakushun"; # Define your hostname.
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      # import the rk3588 module, which contains the configuration for bootloader/kernel/firmware
      nixos-rk3588.nixosModules.orangepi5plus.core
      disko.nixosModules.default
    ];

  networking = {
    inherit hostName;
    inherit (myvars.networking) defaultGateway nameservers;
    inherit (myvars.networking.hostsInterface.${hostName}) interfaces;
    networkmanager.enable = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
