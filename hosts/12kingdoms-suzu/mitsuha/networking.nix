{myvars, ...}: let
  hostName = "mitsuha";
  inherit (myvars.networking) mainGateway nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) ipv4;

  ipv4WithMask = "${ipv4}/24";
in {
  systemd.network.enable = true;

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = [ipv4WithMask];
      Gateway = mainGateway;
      DNS = nameservers;
      DHCP = "no";
    };
  };
}
