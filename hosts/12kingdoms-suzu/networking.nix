{myvars, ...}: let
  hostName = "suzu";
  inherit (myvars.networking) mainGateway nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;

  ipv4WithMask = "${ipv4}/24";
in {
  boot.kernel.sysctl = {
    # forward network packets that are not destined for the interface on which they were received
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  # A bridge to link all VM's TAP interfaces into local network.
  # https://github.com/astro/microvm.nix/blob/main/doc/src/simple-network.md
  systemd.network.networks."10-lan" = {
    # match on the main interface and all VM interfaces
    matchConfig.Name = [iface "vm-*"];
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  # Add ipv4 address to the bridge.
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = [ipv4WithMask];
      Gateway = mainGateway;
      DNS = nameservers;
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
