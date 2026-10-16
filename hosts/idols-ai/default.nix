{
  disko,
  myvars,
  lib,
  pkgs,
  ...
}:
#############################################################
#
#  Ai - my gaming and daily-use desktop. Hardware and the platform history:
#  ./README.md.
#
#############################################################
let
  hostName = "ai"; # Define your hostname.

  inherit (myvars.networking) mainGateway mainGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4 ipv6;
  ipv4WithMask = "${ipv4}/24";
  ipv6WithMask = "${ipv6}/64";
in
{
  imports = [
    disko.nixosModules.default
    # disks
    ./disko-fs.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hardware-intel.nix
    ./hardware-nvidia.nix

    ./preservation.nix
    ./secureboot.nix

    ./restic.nix

    # WA-035: neighbour-probe fallback for the Mesh WiFi backhaul to the homelab.
    ./neighbour-probe.nix

    # others
    ./ai
  ];

  # Zram consumes physical memory for compression, which can cause a deadlock and system hang if the model size approaches the physical memory limit.
  # Disable the whole module (zram device + its swappiness=180 sysctl tunings); this host uses a
  # disk swapfile instead, created by disko at /swap (see ./disko-fs.nix). The two must move together.
  modules.zram.enable = false;

  # zswap: compressed writeback cache in front of the disk swapfile, so cold
  # anonymous pages stay in RAM instead of hitting the SSD. Safe here: the disk
  # swapfile remains the real backing store, no zram deadlock structure.
  # - zstd: ~2.5x the ratio of lz4 for ~5us decompress, which is noise against
  #   the ~100us SSD fault it avoids; the CPU is not the bottleneck.
  # - 10% pool (~3G on 32G): the module default 25% would compete with the page
  #   cache that games and VMs rely on.
  boot.zswap = {
    enable = true;
    compressor = "zstd";
    maxPoolPercent = 10;
  };

  services.sunshine.enable = true;

  modules.btrbk.enable = true;

  # Give the desktop user the render group outright instead of relying only on
  # the logind seat ACL, so local ASR keeps its /dev/dri access in sessions
  # that have no seat (the Sunshine headless session, for example).
  users.users.${myvars.username}.extraGroups = [ "render" ];

  # systemd-journal - cap disk usage
  # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
  services.journald.settings.Journal = {
    SystemMaxUse = "10G";
    RuntimeMaxUse = "256M";
  };

  # Monitor SSD/NVMe SMART attributes so a drive going bad is visible before it
  # fails, and so there is data behind the relaxed NVMe power-management
  # settings in hardware-configuration.nix. smartd autodetects devices and
  # reports to the journal (mail notifications stay off without an MTA).
  services.smartd.enable = true;

  # QEMU/KVM(HostCpuOnly) for local VMs.
  environment.systemPackages = [
    pkgs.qemu_kvm
    pkgs.ddcutil # external monitor control over DDC/CI (brightness, input source)
  ];

  # The external monitors answer DDC/CI on /dev/i2c-*: this loads i2c-dev and installs the
  # udev rules that grant the i2c group and locally logged-in users access, so `ddcutil`
  # works without sudo.
  hardware.i2c.enable = true;

  # The board's ARGB controller is a USB HID device (MSI Mystic Light, 1462:7e01). This
  # module installs openrgb with its udev rules and runs `openrgb --server`, so the GUI and
  # the CLI reach the board without root. `motherboard` needs no value here: it follows
  # hardware.cpu.intel.updateMicrocode, which hardware-configuration.nix already sets.
  services.hardware.openrgb.enable = true;

  # Re-evaluate after the Insta360 Link firmware or the kernel's uvcvideo changes.
  powerManagement.resumeCommands = ''
    # Insta360 Link may stay enumerated with a stalled UVC endpoint after S3 resume.
    ${pkgs.coreutils}/bin/sleep 1
    ${pkgs.usbutils}/bin/usbreset 2e1a:4c01 || true
  '';

  networking = {
    inherit hostName;

    # off: this host uses networkd (below). NetworkManager would otherwise
    # provide nmcli/nmtui for wifi adjustment.
    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  # networkd removes routing policy rules not defined in .network files
  # (ManageForeignRoutingPolicyRules defaults to yes) each time it reconfigures
  # a link. On S3 resume it reconfigures the NIC, which wiped mihomo's
  # (9000-9010) and Tailscale's rules and briefly broke routing. Keep foreign
  # rules so the VPN/TUN rules survive.
  systemd.network.config.networkConfig.ManageForeignRoutingPolicyRules = false;

  # Predictable names follow the PCIe topology, so a board or slot change renames the
  # wired NIC. Match the `en*` prefix instead of a name; one wired port, so one link.
  systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "en*" ];
    networkConfig = {
      Address = [
        ipv4WithMask
        ipv6WithMask
      ];
      DNS = nameservers;
      DHCP = "ipv6"; # enable DHCPv6 only, so we can get a GUA.
      IPv6AcceptRA = true; # for Stateless IPv6 Autoconfiguration (SLAAC)
      LinkLocalAddressing = "ipv6";
      # r8169 drops carrier on S3 resume; without this, networkd tears down the
      # static address/route and mihomo's TUN auto-detect briefly loses its
      # outbound interface, leaving routing broken until mihomo is restarted.
      IgnoreCarrierLoss = "10s";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = mainGateway;
      }
      {
        Destination = "::/0";
        Gateway = mainGateway6;
        GatewayOnLink = true; # it's a gateway on local link.
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # Point this link's DNS at mihomo while it runs, and revert it when it stops.
  #
  # Why a lifecycle hook: mihomo's sing-tun stack would call resolvectl itself,
  # but nixpkgs' DynamicUser+hardened unit closes the D-Bus socket and SetLinkDNS
  # needs privileged authorization; without the takeover resolved's upstream
  # queries bypass dns-hijack and leave via the NIC. The '+' prefix escapes that
  # sandbox -- a failed ExecStartPost would kill a healthy service -- and
  # ExecStopPost also runs on crashes, so a dead mihomo leaves the network usable.
  #
  # Why the probe: the core opens :1053 only after parsing the rules, and rule
  # parsing is where missing geodata gets fetched. Flipping at fork time pointed
  # that fetch at a port nobody was listening on -- SERVFAIL, a fatal config
  # error, a unit that could never start.
  # The hook names the link with `hostsAddr.ai.iface`: networkd matches an `en*`
  # prefix, but `resolvectl` takes one name or index, not a pattern.
  systemd.services.mihomo.serviceConfig = {
    ExecStartPost = lib.mkDefault "+${pkgs.writeShellScript "mihomo-dns-takeover" ''
      probe() { (exec 3<>/dev/tcp/127.0.0.1/1053) 2>/dev/null; }
      up=0
      for ((i = 0; i < 100; i++)); do
        if probe; then up=1; break; fi
        sleep 0.1
      done
      if [ "$up" = 0 ]; then
        echo "mihomo never opened 127.0.0.1:1053; leaving ${iface} on its own DNS" >&2
        exit 0
      fi
      exec ${pkgs.systemd}/bin/resolvectl dns ${iface} 127.0.0.1:1053
    ''}";
    ExecStopPost = lib.mkDefault "+${pkgs.systemd}/bin/resolvectl revert ${iface}";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
