{
  pkgs,
  hostName,
  networking,
  ...
}:
let
  inherit (networking) proxyGateway proxyGateway6;
  inherit (networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in
{
  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
    "nfs"
  ];

  # KVM for the microVMs and the libvirt domains.
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu

  boot.kernel.sysctl = {
    # --- filesystem --- #
    # increase the limits to avoid running out of inotify watches
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;

    # --- network --- #
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.core.somaxconn" = 32768;

    # ----- IPv4 ----- #
    "net.ipv4.ip_forward" = 1; # Enable forwarding
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.neigh.default.gc_thresh1" = 4096;
    "net.ipv4.neigh.default.gc_thresh2" = 6144;
    "net.ipv4.neigh.default.gc_thresh3" = 8192;
    "net.ipv4.neigh.default.gc_interval" = 60;
    "net.ipv4.neigh.default.gc_stale_time" = 120;
    # ----- IPv6 ----- #
    "net.ipv6.conf.all.forwarding" = 1; # Enable forwarding

    # NOTE: vm.swappiness is intentionally NOT set here; it comes from
    # modules/nixos/base/zram.nix (mkDefault 180, tuned for the zram device).
  };

  # zram itself is provided by modules/nixos/base/zram.nix (enabled by default).
  # Kill the greediest process before the host starts thrashing / gets OOM-killed.
  services.earlyoom.enable = true;

  environment.systemPackages = with pkgs; [
    # Validate Hardware Virtualization Support via:
    #   virt-host-validate qemu
    libvirt
  ];

  networking = {
    inherit hostName;

    # we use networkd instead
    networkmanager.enable = false;
    useDHCP = false;
  };
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Linux bridge for the VMs: the microVM taps and the libvirt domains attach to
  # br0, and the host keeps its own address on it (the physical NIC is just a
  # bridge port).
  systemd.network.netdevs."10-br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  # Set the host's address on the bridge interface instead of the physical interface!
  systemd.network.networks = {
    "10-br0" = {
      matchConfig.Name = [ "br0" ];
      networkConfig = {
        Address = [ ipv4WithMask ];
        # DNS = nameservers;
        DNS = [ proxyGateway ];
        DHCP = "ipv6"; # enable DHCPv6 only, so we can get a GUA.
        IPv6AcceptRA = true; # for Stateless IPv6 Autoconfiguraton (SLAAC)
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
          GatewayOnLink = true; # it's a gateway on local link.
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-${iface}" = {
      matchConfig.Name = [ iface ];
      networkConfig = {
        LinkLocalAddressing = "no";
        # attach the physical NIC to the Linux bridge br0
        Bridge = "br0";
      };
      linkConfig.RequiredForOnline = "no";
    };
  };

  # systemd-journal - cap disk usage, but keep plenty of history on the big
  # persistent disk (/var/log is preserved to /persistent).
  # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
  services.journald.settings.Journal = {
    SystemMaxUse = "10G";
    RuntimeMaxUse = "256M";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
