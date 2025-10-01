{
  lib,
  pkgs,
  ...
}:
# =============================================================
#
# NetBird - your own private network(VPN) that uses WireGuard, Coturn, etc.
#
# It's similar to tailscale, but netbird's more opensouse and less mature.
#
# NetBird natively supports running multiple clients on the same host — something
#   Tailscale can’t do easily.
# Its NixOS module ships a dedicated CLI wrapper for every client, so managing them is effortless.
#
# How to use:
#  1. Create a NetBird account at https://app.netbird.io/
#  3. Login & join into your homelab network via `netbird-homelab up`
#
# Status Data:
#   `journalctl -u netbird-homelab` shows netbird's logs
#   netbird client store its data in /var/lib/netbird-homelab
#   which is already persistent across reboots(via preservation)
#
# References:
#  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/netbird.nix
#
# =============================================================
{
  services.netbird.useRoutingFeatures = "client";
  services.netbird.clients.homelab = {
    port = 51820;
    name = "homelab";
    interface = "netbird-homelab";
    hardened = true;
    autoStart = true;
  };
}
