{
  config,
  lib,
  myvars,
  pkgs,
  ...
}:
let
  dataDir = "/data/fileshare/public/transmission";
  name = "transmission";

  # Transmission runs in its own network namespace with a direct path to the
  # main router: the default host gateway is suzi, a transparent proxy that
  # hijacks DNS to fake IPs (which only resolve on the proxied path) and has no
  # UPnP/NAT-PMP. In the namespace it gets its own address, a real resolver, and
  # a default route at the main router, so peers can reach it and it can resolve
  # real addresses without going through the proxy.
  netns = "transmission";
  nsIp = "192.168.5.118";
  hostVeth = "tr-hveth";
  nsVeth = "tr-nveth";

  # Real resolvers for the namespace (v4 first; the host's resolver is suzi).
  resolvConf = pkgs.writeText "transmission-resolv.conf" (
    lib.concatMapStrings (ns: "nameserver ${ns}\n") myvars.networking.nameservers
  );

  # Drop nss-resolve from the host's nsswitch for this service only: it talks to
  # the host's resolved over a unix socket, which would resolve through suzi and
  # return fake IPs again, bypassing the resolvers above.
  nsswitchConf = pkgs.runCommand "transmission-nsswitch.conf" { } ''
    sed -E 's/ resolve \[!UNAVAIL=return\]//' ${config.environment.etc."nsswitch.conf".source} > $out
  '';

  ip = "${pkgs.iproute2}/bin/ip";
  sysctl = "${pkgs.procps}/bin/sysctl";
  nft = "${pkgs.nftables}/bin/nft";

  # The namespace is a first-class host on br0, so once the router's IPv6
  # firewall is relaxed it is reachable from the Internet with no host firewall
  # in front of it. Keep the peer port open (that is the point) and the RPC
  # LAN-only; drop everything else.
  netnsFirewall = pkgs.writeText "transmission-netns.nft" ''
    table inet transmission-fw {
      chain input {
        type filter hook input priority filter; policy drop;
        iif "lo" accept
        ct state established,related accept
        meta l4proto icmp accept
        meta l4proto ipv6-icmp accept
        tcp dport 51413 accept
        udp dport 51413 accept
        udp dport 6771 accept
        ip saddr ${myvars.networking.lanCidr} tcp dport 9091 accept
      }
    }
  '';
in
{
  # Join the shared fileshare group so transmission can read/write files
  # created by sftpgo, and vice versa (via setgid directories).
  users.users.${name}.extraGroups = [ "fileshare" ];

  # Set up transmission's home dir with setgid + fileshare group ownership.
  # The setgid bit (2) causes all files created here to inherit the group
  # 'fileshare', regardless of which service creates them.
  systemd.tmpfiles.rules = [
    # Keep shared parent owned by root to avoid tmpfiles "unsafe path transition"
    # when another service creates subdirectories under /data/fileshare/public.
    "d /data/fileshare 2775 root fileshare -"

    "d ${dataDir} 2775 ${name} fileshare -"
    "d ${dataDir}/incomplete 2775 ${name} fileshare -"
    "d ${dataDir}/downloads 2775 ${name} fileshare -"
    "d ${dataDir}/watch 2775 ${name} fileshare -"
  ];

  # the headless Transmission BitTorrent daemon
  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/torrent/transmission.nix
  # https://wiki.archlinux.org/title/transmission
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = name;
    group = name;
    # 2775: setgid preserves fileshare group on download/incomplete dirs.
    downloadDirPermissions = "2775";

    # Whether to enable tweaking of kernel parameters to open many more connections at the same time.
    # Note that you may also want to increase peer-limit-global.
    # And be aware that these settings are quite aggressive and might not suite your regular desktop use.
    # For instance, SSH sessions may time out more easily.
    performanceNetParameters = true;

    # Path to a JSON file to be merged with the settings.
    # Useful to merge a file which is better kept out of the Nix store to set secret config parameters like `rpc-password`.
    credentialsFile = config.age.secrets."transmission-credentials.json".path;

    # Whether to open the RPC port in the firewall.
    openRPCPort = false;
    openPeerPorts = true;

    # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
    settings = {
      # 0 = None, 1 = Critical, 2 = Error, 3 = Warn, 4 = Info, 5 = Debug, 6 = Trace;
      message-level = 3;

      # Encryption may help get around some ISP filtering,
      # but at the cost of slightly higher CPU use.
      # 0 = Prefer unencrypted connections,
      # 1 = Prefer encrypted connections,
      # 2 = Require encrypted connections; default = 1)
      # Keep it at "prefer": forcing encryption drops peers that cannot do
      # MSE, which costs upload opportunities on public swarms.
      encryption = 1;

      # rpc = Web Interface
      rpc-port = 9091;
      # The netns has its own loopback, so caddy (on the host) reaches the RPC
      # over the namespace address instead of 127.0.0.1. Plain HTTP on the LAN;
      # the RPC auth and whitelists below still apply.
      rpc-bind-address = nsIp;
      anti-brute-force-enabled = true;
      # After this amount of failed authentication attempts is surpassed,
      # the RPC server will deny any further authentication attempts until it is restarted.
      # This is not tracked per IP but in total.
      # Health-check probes (homepage/uptime-kuma) hit the authenticated RPC
      # gateway and each 401 counts, so keep this well above a 401 burst.
      anti-brute-force-threshold = 100;
      rpc-authentication-required = true;

      # Comma-delimited list of IP addresses.
      # Wildcards allowed using '*'. Example: "127.0.0.*,192.168.*.*",
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.*,192.168.*.*";
      # Comma-delimited list of domain names.
      # Wildcards allowed using '*'. Example: "*.foo.org,example.com",
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = "*.writefor.fun,localhost,192.168.5.*";
      rpc-user = myvars.username;
      rpc-username = myvars.username;
      # rpc-password = "test"; # you'd better use the credentialsFile for this.

      incomplete-dir-enabled = true;
      incomplete-dir = "${dataDir}/incomplete";
      download-dir = "${dataDir}/downloads";

      # Watch a directory for torrent files and add them to transmission.
      watch-dir-enabled = false;
      watch-dir = "${dataDir}/watch";
      # Whether to enable Micro Transport Protocol (µTP).
      utp-enabled = true;
      # Executable to be run at torrent completion.
      script-torrent-done-enabled = false;
      # script-torrent-done-filename = "/path/to/script";

      # Enable Local Peer Discovery (LPD).
      lpd-enabled = true;
      # The peer port to listen for incoming connections.
      peer-port = 51413;
      # Bind peer sockets to the namespace address, so the listener, outgoing
      # source, and UPnP/NAT-PMP advertisement all use the address the main
      # router forwards 51413 to.
      bind-address-ipv4 = nsIp;
      # Enable UPnP or NAT-PMP to forward a port through your firewall(NAT).
      # https://github.com/transmission/transmission/blob/main/docs/Port-Forwarding-Guide.md
      port-forwarding-enabled = true;

      # "normal" speed limits
      speed-limit-down-enabled = true;
      speed-limit-down = 30000; # KB/s
      # Keep seeding under the 50 Mbps uplink (~20 Mbps).
      speed-limit-up-enabled = true;
      speed-limit-up = 2500; # KB/s
      upload-slots-per-torrent = 16;

      # Start torrents as soon as they are added
      start-added-torrents = true;

      # Queuing
      # When true, Transmission will only download
      # download-queue-size non-stalled torrents at once.
      download-queue-enabled = true;
      download-queue-size = 10;

      # When true, torrents that have not shared data for
      # queue-stalled-minutes are treated as 'stalled'
      # and are not counted against the queue-download-size
      # and seed-queue-size limits.
      queue-stalled-enabled = true;
      queue-stalled-minutes = 60;

      # When true. Transmission will only seed seed-queue-size
      # non-stalled torrents at once.
      seed-queue-enabled = true;
      # With 30+ torrents, 10 was leaving most seeds queued (never uploading).
      seed-queue-size = 50;
    };
  };

  # Create the namespace and its veth (the host end becomes another port on
  # br0), so the service below can join it and appear as its own LAN host.
  systemd.services.transmission-netns = {
    description = "Network namespace for transmission";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-networkd.service" ];
    preStart = ''
      for _ in $(seq 1 30); do
        ${ip} link show br0 >/dev/null 2>&1 && break
        sleep 1
      done
      ${ip} link show br0 >/dev/null 2>&1 || { echo "br0 is not ready" >&2; exit 1; }
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${ip} netns del ${netns}";
    };
    script = ''
      set -euo pipefail
      # idempotent: clean up leftovers from an unclean stop
      ${ip} netns del ${netns} 2>/dev/null || true
      ${ip} link del ${hostVeth} 2>/dev/null || true

      ${ip} netns add ${netns}
      ${ip} link add ${hostVeth} type veth peer name ${nsVeth}
      ${ip} link set ${hostVeth} master br0
      ${ip} link set ${hostVeth} up
      ${ip} link set ${nsVeth} netns ${netns}

      ${ip} -n ${netns} link set lo up
      # Pin the MAC so the SLAAC-based IPv6 address is stable across reboots.
      ${ip} -n ${netns} link set ${nsVeth} address 02:00:00:00:76:01
      # Keep a stable address: temporary addresses rotate and would not match
      # what transmission listens on and advertises.
      ${ip} netns exec ${netns} ${sysctl} -q -w net.ipv6.conf.${nsVeth}.use_tempaddr=0 || true
      ${ip} -n ${netns} link set ${nsVeth} up
      ${ip} -n ${netns} addr add ${nsIp}/24 dev ${nsVeth}
      ${ip} -n ${netns} route add default via ${myvars.networking.mainGateway}

      # Apply the namespace firewall after the interface is up.
      ${ip} netns exec ${netns} ${nft} -f ${netnsFirewall}
    '';
  };

  # Join the namespace and resolve through real resolvers instead of suzi.
  systemd.services.transmission = {
    after = [ "transmission-netns.service" ];
    requires = [ "transmission-netns.service" ];
    # restart together with the namespace; otherwise the service would stay in
    # the deleted namespace after the netns unit is recreated
    partOf = [ "transmission-netns.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${netns}";
      # Joining a namespace owned by the host is incompatible with the module's
      # default PrivateUsers=; the rest of the sandbox stays in place.
      PrivateUsers = false;
      # Resolve directly instead of through the host's systemd-resolved (suzi).
      BindReadOnlyPaths = [
        "${resolvConf}:/etc/resolv.conf"
        "${nsswitchConf}:/etc/nsswitch.conf"
      ];
      # glibc's resolver uses netlink to pick source addresses; the module's
      # default set does not include it.
      RestrictAddressFamilies = [ "AF_NETLINK" ];
    };
  };

  # The /data mounts are `nofail`, so nothing orders transmission after them;
  # without this the unit can start before /data/fileshare/public is mounted and
  # fail its mount-namespace setup (seen on the host, where the tasks race).
  systemd.services.transmission.unitConfig.RequiresMountsFor = "/data/fileshare/public";
}
