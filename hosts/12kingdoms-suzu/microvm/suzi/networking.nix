{
  lib,
  myvars,
  ...
}: let
  hostName = "suzi";
  inherit (myvars.networking) mainGateway nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) ipv4;

  ipv4WithMask = "${ipv4}/24";
  dhcpRange = {
    start = "192.168.5.5";
    end = "192.168.5.99";
  };
in {
  boot.kernel.sysctl = {
    # https://github.com/ghostbuster91/blogposts/blob/main/router2023-part2/main.md
    # https://github.com/daeuniverse/dae/blob/main/docs/en/user-guide/kernel-parameters.md
    # forward network packets that are not destined for the interface on which they were received
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.br-lan.rp_filter" = 1;
    "net.ipv4.conf.br-lan.send_redirects" = 0;
  };

  # Docker uses iptables internally to setup NAT for containers.
  # This module disables the ip_tables kernel module, which is required for nftables to work.
  # So make sure to disable docker here.
  virtualisation.docker.enable = lib.mkForce false;
  networking = {
    useNetworkd = true;

    useDHCP = false;
    networkmanager.enable = false;
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    # No local firewall.
    nat.enable = false;
    firewall.enable = false;

    # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/networking/nftables.nix
    nftables = {
      enable = true;
      # Check the applied rules with `nft -a list ruleset`.
      # Since this is a internal bypass router, we don't need to do NAT & can forward all traffic.
      ruleset = ''
        # Check out https://wiki.nftables.org/ for better documentation.
        # Table for both IPv4 and IPv6.
        table inet filter {
          chain input {
            type filter hook input priority 0;

            # accept any localhost traffic
            iifname lo accept

            # accept any lan traffic
            iifname br-lan accept

            # count and drop any other traffic
            counter drop
          }

          # Allow all outgoing connections.
          chain output {
            type filter hook output priority 0;
            accept
          }

          # Allow all forwarding all traffic.
          chain forward {
            type filter hook forward priority 0;
            accept
          }
        }
      '';
    };
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  systemd.network = {
    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };
    # This is a bypass router, so we do not need a wan interface here.
    networks = {
      "30-lan0" = {
        # match the interface by type
        matchConfig.Type = "ether";
        # Connect to the bridge
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      # Configure the bridge device we just created
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        address = [
          # configure addresses including subnet mask
          ipv4WithMask # forwards all traffic to the gateway except for the router address itself
        ];
        routes = [
          # forward all traffic to the main gateway
          {routeConfig.Gateway = mainGateway;}
        ];
        bridgeConfig = {};
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # resolved is conflict with dnsmasq
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    # resolve local queries (add 127.0.0.1 to /etc/resolv.conf)
    resolveLocalQueries = true; # may be conflict with dae, disable this.
    alwaysKeepRunning = true;
    # https://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=tree
    settings = {
      # upstream DNS servers
      server = nameservers;
      # forces dnsmasq to try each query with each server strictly
      # in the order they appear in the config.
      strict-order = true;

      # Never forward plain names (without a dot or domain part)
      domain-needed = true;
      # Never forward addresses in the non-routed address spaces(e.g. private IP).
      bogus-priv = true;
      # don't needlessly read /etc/resolv.conf which only contains the localhost addresses of dnsmasq itself.
      no-resolv = true;

      # Cache dns queries.
      cache-size = 1000;

      dhcp-range = ["${dhcpRange.start},${dhcpRange.end},24h"];
      interface = "br-lan";
      dhcp-sequential-ip = true;
      dhcp-option = [
        # Override the default route supplied by dnsmasq, which assumes the
        # router is the same machine as the one running dnsmasq.
        "option:router,${ipv4}"
        "option:dns-server,${ipv4}"
      ];

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts
      no-hosts = true;
      address = [
        # "/surfer.lan/192.168.10.1"
      ];
    };
  };

  # monitoring with prometheus
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/monitoring/prometheus/exporters/dnsmasq.nix
  services.prometheus.exporters.dnsmasq = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9153;
    openFirewall = false;
    leasesPath = "/var/lib/dnsmasq/dnsmasq.leases";
  };

  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of
  # letting the first CPU core to handle everything.
  # This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = false;
}
