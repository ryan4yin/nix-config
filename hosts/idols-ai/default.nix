{myvars, ...}:
#############################################################
#
#  Ai - my main computer, with NixOS + I5-13600KF + RTX 4090 GPU, for gaming & daily use.
#
#############################################################
let
  hostName = "ai"; # Define your hostname.

  inherit (myvars.networking) defaultGateway defaultGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4 ipv6;
  ipv4WithMask = "${ipv4}/24";
  ipv6WithMask = "${ipv6}/64";
in {
  imports = [
    ./netdev-mount.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix

    ./impermanence.nix
    ./secureboot.nix
  ];

  networking = {
    inherit hostName;

    # desktop need its cli for status bar & wifi network.
    networkmanager.enable = true;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Add ipv4 address to the bridge.
  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [iface];
    networkConfig = {
      Address = [ipv4WithMask ipv6WithMask];
      DNS = nameservers;
      DHCP = "ipv6"; # enable DHCPv6 only, so we can get a GUA.
      IPv6AcceptRA = true; # for Stateless IPv6 Autoconfiguraton (SLAAC)
      LinkLocalAddressing = "ipv6";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = defaultGateway;
      }
      {
        Destination = "::/0";
        Gateway = defaultGateway6;
        GatewayOnLink = true; # it's a gateway on local link.
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # conflict with feature: containerd-snapshotter
  # virtualisation.docker.storageDriver = "btrfs";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
