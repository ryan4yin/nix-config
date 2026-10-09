{
  pkgs,
  hostName,
  networking,
  # vCPU count and RAM (MiB) for the QEMU guest
  vcpu,
  mem,
  # persistent volume sizes in MiB
  etcSize ? 64,
  varSize ? 4096,
  homeSize ? 4096,
  # extra stateful mounts (e.g. aquamarine's /data on the passed-through HDDs)
  extraVolumes ? [ ],
  ...
}:
let
  inherit (networking) proxyGateway proxyGateway6 clusterULA6;
  inherit (networking.hostsAddr.${hostName}) ipv4;
  ipv4WithMask = "${ipv4}/24";

  # deterministic MAC per guest so the tap is stable and the guest can match its
  # NIC by MAC (the qemu NIC name inside the guest is not enp2s0)
  octets = builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)" ipv4;
  toHex =
    n:
    let
      h = pkgs.lib.toHexString (builtins.fromJSON n);
    in
    if builtins.stringLength h == 1 then "0${h}" else h;
  mac = "02:00:00:00:${toHex (builtins.elemAt octets 2)}:${toHex (builtins.elemAt octets 3)}";

  # Same octets as the MAC: 192.168.5.111 -> fd05:5::05:6f. Survives ISP prefix changes.
  ula = pkgs.lib.toLower "${clusterULA6}${toHex (builtins.elemAt octets 2)}:${toHex (builtins.elemAt octets 3)}/64";

  # tap iface name on the host (IFNAMSIZ is 16, so <= 15 chars). All homelab VMs
  # are 192.168.5.0/24, so the last octet is unique per host.
  tapId = "vm${builtins.elemAt octets 3}";
in
{
  # The guest is a MicroVM: the root is in RAM, /nix/store is the host's
  # (read-only, via virtiofs) so no OS image has to be built or uploaded --
  # everything here comes from this flake. Only the *stateful* paths below are
  # on real volumes and therefore survive a reboot.
  microvm = {
    hypervisor = "qemu";
    inherit vcpu mem;
    socket = "control.socket";

    interfaces = [
      {
        type = "tap";
        id = tapId;
        inherit mac;
      }
    ];

    shares = [
      {
        tag = "ro-store";
        proto = "virtiofs";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    volumes = [
      {
        mountPoint = "/etc"; # ssh host keys (the agenix age identity!), machine-id
        image = "etc.img";
        size = etcSize;
      }
      {
        mountPoint = "/var"; # k3s data (/var/lib/rancher/k3s), nixos uid/gid maps
        image = "var.img";
        size = varSize;
      }
      {
        mountPoint = "/home"; # user data
        image = "home.img";
        size = homeSize;
      }
    ]
    ++ extraVolumes;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = false;
    useDHCP = false;
    # Keep node IPv6 addresses stable for Cilium across agent restarts.
    tempAddresses = "disabled";
  };
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # match the virtio NIC by MAC: qemu names it something like enp0s1, not enp2s0
  systemd.network.networks."10-${hostName}" = {
    matchConfig.MACAddress = [ mac ];
    networkConfig = {
      Address = [
        ipv4WithMask
        ula
      ];
      DNS = [ proxyGateway ];
      # No SLAAC/DHCPv6: the WAN /64 churns and Cilium keeps probing whatever it
      # registered at agent start. The ULA above is the node's IPv6 identity.
      DHCP = false;
      IPv6AcceptRA = false;
      IPv6PrivacyExtensions = false;
      LinkLocalAddressing = "ipv6";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = proxyGateway;
      }
      {
        Destination = "::/0";
        Gateway = proxyGateway6;
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # No ULA counterpart to the LAN IPv4 accept in
  # modules/nixos/base/networking/firewall.nix, so Cilium's node health probe
  # (TCP 4240) between nodes is dropped. Trust the node plane like the LAN.
  networking.firewall.extraInputRules = pkgs.lib.mkAfter ''
    ip6 saddr ${clusterULA6}/64 accept
  '';

  # journald on tmpfs -- keep it small
  services.journald.settings.Journal = {
    SystemMaxUse = "512M";
    RuntimeMaxUse = "256M";
  };

  system.stateVersion = "26.05";

  # The guest shares the host's read-only /nix/store (virtiofs) and has no store
  # of its own, so its nix-gc.service can never succeed; it just failed on every
  # k3s guest and tripped HostSystemdServiceCrashed. The host's own nix.gc
  # reclaims the shared store, so disable automatic GC inside the guest.
  nix.gc.automatic = false;

  # MicroVM guests share the host's store and have no physical hardware to
  # inspect, nothing to trace, no persisted /var/cache for a `locate` index,
  # and nothing to advertise over mDNS.
  modules.hardwareTools.enable = false;
  modules.debugTools.enable = false;
  modules.locate.enable = false;
  modules.mdns.enable = false;
}
