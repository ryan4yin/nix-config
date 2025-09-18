{
  # enable tailscale on aquamarine
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      # access home network via tailscale
      "--advertise-routes=192.168.5.0/24"
    ];
  };
}
