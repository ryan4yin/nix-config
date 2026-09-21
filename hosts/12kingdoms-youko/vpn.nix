{
  pkgs,
  myvars,
  ...
}:
let
  inherit (myvars.networking) hostsAddr k8sVip;
in
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
      # Advertise only youko itself and the k8s VIP block, not the whole /24:
      # a /24 route would shadow hosts that are already reachable directly
      # (e.g. idols-ai at 192.168.5.100).
      "--advertise-routes=${hostsAddr.youko.ipv4}/32,${k8sVip.cidr}"
      "--accept-routes=false"
    ];
  };
}
