{
  # nixos-jh7110,
  vars_networking,
  ...
}:
#############################################################
#
#  Chiaya - NixOS Configuration for Milk-V Mars
#
#  WIP, not working yet.
#
#############################################################
let
  hostName = "chiaya"; # Define your hostname.
  hostAddress = vars_networking.hostAddress.${hostName};
in {
  imports = [
  ];

  # Set static IP address / gateway / DNS servers.
  networking = {
    inherit hostName;
    inherit (vars_networking) defaultGateway nameservers;

    # Failed to enable firewall due to the following error:
    #   firewall-start[2300]: iptables: Failed to initialize nft: Protocol not supported
    firewall.enable = false;
    networkmanager.enable = false;
    # milkv-mars RJ45 port
    interfaces.end0 = {
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
  system.stateVersion = "23.05"; # Did you read the comment?
}
