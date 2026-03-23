{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # allow the Tailscale UDP port through the firewall
    openFirewall = true;

    useRoutingFeatures = "server";
    extraSetFlags = [
      # advertise homelab subnet via tailscale
      "--advertise-routes=192.168.5.0/24"
      "--accept-routes=false"
    ];
  };
}
