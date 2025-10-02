{
  # tailscale do not support running multiple clients on the same host,
  # so we use netbird for homelab instead.
  #
  # services.tailscale = {
  #   enable = true;
  #   port = 41641;
  #   interfaceName = "tailscale0";
  #   # allow the Tailscale UDP port through the firewall
  #   openFirewall = true;
  #
  #   useRoutingFeatures = "server";
  #   extraSetFlags = [
  #     # access home network via tailscale
  #     "--advertise-routes=192.168.5.0/24"
  #     "--accept-routes=false"
  #   ];
  # };

  services.netbird.useRoutingFeatures = "server";
  services.netbird.clients.homelab = {
    port = 51820;
    name = "homelab";
    interface = "netbird-homelab";
    hardened = true;
    autoStart = true;
  };
}
