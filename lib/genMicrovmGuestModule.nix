{
  pkgs,
  hostName,
  networking,
  # vCPU count and RAM (MiB) -- mirrors the KubeVirt instancetype
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
  inherit (networking) proxyGateway proxyGateway6;
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
  };
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # match the virtio NIC by MAC: qemu names it something like enp0s1, not enp2s0
  systemd.network.networks."10-${hostName}" = {
    matchConfig.MACAddress = [ mac ];
    networkConfig = {
      Address = [ ipv4WithMask ];
      DNS = [ proxyGateway ];
      DHCP = "ipv6";
      IPv6AcceptRA = true;
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

  # journald on tmpfs -- keep it small
  services.journald.settings.Journal = {
    SystemMaxUse = "512M";
    RuntimeMaxUse = "256M";
  };

  system.stateVersion = "26.05";
}
