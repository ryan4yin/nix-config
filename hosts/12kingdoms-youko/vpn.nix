{
  myvars,
  ...
}:
let
  inherit (myvars.networking) hostsAddr k8sVip;
in
{
  # `services.tailscale` already puts the CLI in `environment.systemPackages`.

  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # No-op here: the shared firewall opens 41641 in `extraInputRules` and
    # forces `allowedUDPPorts` empty.
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
