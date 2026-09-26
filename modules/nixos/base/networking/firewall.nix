{ lib, myvars, ... }:
let
  inherit (myvars.networking) lanCidr;
  # The host that scrapes the exporters (VictoriaMetrics runs on youko).
  monitoringHost = myvars.networking.hostsAddr.youko.ipv4;
in
{
  # Hosts bring their own firewall as defence in depth behind the router's
  # (which stays on, with port mappings for the few ports we need): the home
  # LAN and the tailnet are trusted equally (tighten the tailnet with Tailscale
  # ACLs), and everything else is denied on both address families.
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;

    # Nothing is opened to the Internet. LAN/tailnet/local-container access
    # comes from the rules below; per-service `openFirewall` ports are
    # suppressed.
    allowedTCPPorts = lib.mkForce [ ];
    allowedUDPPorts = lib.mkForce [ ];

    extraInputRules = ''
      # node_exporter is scraped only by the monitoring host, not the whole
      # LAN/tailnet/local containers.
      ip saddr != ${monitoringHost} tcp dport 9100 drop

      # The local container bridge and the tailnet have the same access as the
      # LAN. Kept after the drop above so neither can reach node_exporter.
      iifname "podman0" accept
      iifname "tailscale0" accept

      # The home LAN is the trusted core.
      ip  saddr ${lanCidr} accept
      ip6 saddr fe80::/10 accept
      # Tailscale's WireGuard port, for direct (non-DERP) connections.
      udp dport 41641 accept
    '';
  };
}
