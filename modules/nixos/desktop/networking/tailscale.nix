{
  # enable tailscale on aquamarine
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes"
    ];
  };
}
