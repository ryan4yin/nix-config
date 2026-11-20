# Joins the tailnet shared with friends: ./README.md#friends-tailnet.
{
  # `services.tailscale` already puts the CLI in `environment.systemPackages`.

  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # No-op here: the shared firewall opens 41641 in `extraInputRules` and
    # forces `allowedUDPPorts` empty.
    openFirewall = true;

    extraSetFlags = [
      # Friends' devices share this tailnet: their routes must not shadow the
      # home LAN, and its DNS settings must not replace the proxy gateway.
      "--accept-routes=false"
      "--accept-dns=false"
    ];
  };
}
