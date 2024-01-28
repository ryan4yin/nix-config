_: {
  # https://github.com/ghostbuster91/blogposts/blob/main/router2023-part2/main.md
  boot = {
    kernel = {
      sysctl = {
        # forward network packets that are not destined for the interface on which they were received
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        "net.ipv4.conf.br-lan.rp_filter" = 1;
        "net.ipv4.conf.wan.rp_filter" = 1;
      };
    };
  };

  networking = {
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    useNetworkd = true;
    useDHCP = false;

    # No local firewall.
    nat.enable = false;
    firewall.enable = false;

    nftables = {
      enable = true;
      checkRuleset = false;
      # Since this is a internal bypass router, we don't need to do NAT,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          7.
      ruleset = ''
        table inet filter {
           flowtable f {
             hook ingress priority 0;
             devices = { "ens18" };
             flags offload;
           }

          chain input {
            type filter hook input priority 0; policy drop;

            iifname { "br-lan" } accept comment "Allow local network to access the router"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;
            ip protocol { tcp, udp } ct state { established } flow offload @f comment "Offload tcp/udp established traffic"

            iifname { "br-lan" } oifname { "br-lan" } accept comment "Allow LAN to LAN"
          }
        }
      '';
    };
  };

  # https://wiki.archlinux.org/title/systemd-networkd
  systemd.network = {
    wait-online.anyInterface = true;
    netdevs = {
      # Create the bridge interface
      # it works as a switch, so that all the lan ports can communicate with each other at layer 2
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };
    networks = {
      # Connect the bridge ports to the bridge
      "30-lan0" = {
        matchConfig.Name = "ens18";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
    };
  };
  services.resolved.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      # upstream DNS servers
      server = [
        "119.29.29.29" # DNSPod
        "223.5.5.5" # AliDNS
        # "8.8.8.8"
        # "1.1.1.1"
      ];
      # sensible behaviours
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      # Cache dns queries.
      cache-size = 1000;

      dhcp-range = ["br-lan,192.168.5.50,192.168.5.100,24h"];
      interface = "br-lan";
      dhcp-host = "192.168.5.101";

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts as this would advertise surfer as localhost
      no-hosts = true;
      address = [
        # "/surfer.lan/192.168.10.1"
      ];
    };
  };

  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of
  # letting the first CPU core to handle everything.
  # This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = false;
}
