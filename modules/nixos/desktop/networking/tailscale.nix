{
  ...
}:
# =============================================================
#
# Tailscale - your own private network(VPN) that uses WireGuard
#
# It's open source and free for personal use,
# and it's really easy to setup and use.
# Tailscale has great client coverage for Linux, windows, Mac, android, and iOS.
# Tailscale is more mature and stable compared to other alternatives such as netmaker.
#
# How to use:
#  1. Create a Tailscale account at https://login.tailscale.com
#  2. Login via `tailscale login`
#  3. join into your Tailscale network via `tailscale up --accept-routes`
#  4. If you prefer automatic connection to Tailscale, use the `authKeyFile` option` in the config below.
#
# Status Data:
#   `journalctl -u tailscaled` shows tailscaled's logs
#   logs indicate that tailscale store its data in /var/lib/tailscale
#   which is already persistent across reboots(via preservation)
#
# References:
# https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/networking/tailscale.nix
#
# =============================================================
{
  # `services.tailscale` already puts the CLI in `environment.systemPackages`.

  # enable the tailscale service
  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # No-op here: the shared firewall opens 41641 in `extraInputRules` and
    # forces `allowedUDPPorts` empty.
    openFirewall = true;

    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes"
    ];
  };
}
