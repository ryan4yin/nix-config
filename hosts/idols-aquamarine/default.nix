{
  disko,
  myvars,
  lib,
  pkgs-npu,
  ...
}:
#############################################################
#
#  Aquamarine - headless AI inference server. Hardware, install and runbook:
#  ./README.md.
#
#############################################################
let
  hostName = "aquamarine"; # Define your hostname.

  inherit (myvars.networking) proxyGateway proxyGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) ipv4;
  ipv4WithMask = "${ipv4}/24";
in
{
  imports = [
    disko.nixosModules.default
    ../../modules/nixos/power.nix
    # disks
    ./disko-fs.nix

    # hardware
    ./hardware-configuration.nix
    ./hardware-amd-gpu.nix
    ./hardware-intel-igpu.nix

    ./preservation.nix
    ./secureboot.nix

    # services
    ./asr.nix
  ];

  # Bind the board's NCT6798D SuperIO, otherwise fan RPM and board temperatures
  # are missing.
  boot.kernelModules = [ "nct6775" ];

  # Zram consumes physical memory for compression, which deadlocks when the
  # model being loaded approaches the physical memory limit — exactly the
  # workload this host exists for. Use the disk swapfile that disko creates at
  # /swap instead, and keep zswap as a compressed cache in front of it so cold
  # anonymous pages stay in RAM rather than hitting the SSD.
  modules.zram.enable = false;
  boot.zswap = {
    enable = true;
    compressor = "zstd";
    # 10% of 96G; the module default 25% would compete with the page cache that
    # holds the model weights being read in.
    maxPoolPercent = 10;
  };

  # Local btrfs snapshots of @persistent (SSH host keys, /etc/secureboot, the
  # NixOS state). Same layout as the other physical hosts; no off-host target.
  modules.btrbk.enable = true;

  # smartd autodetects devices and logs to the journal; the smartctl exporter
  # (modules/nixos/base/monitoring.nix) is what feeds wear and media errors to
  # VictoriaMetrics.
  services.smartd.enable = true;

  # The inference engine ships as an OCI image and is meant to run rootless, so
  # `podman` is what this host uses to build and start it from the `~/src` checkout
  # that ./preservation.nix keeps.
  virtualisation.podman.enable = true;

  # Keep the user systemd manager running after logout and start it at boot,
  # so enabled user services can run without an active login session.
  users.users."${myvars.username}".linger = true;

  # Speech recognition runs on the NPU, see ./asr.nix. The driver and the
  # compiler it loads come from NixOS/nixpkgs#570230, which is unmerged, so they
  # are taken from that branch as `pkgs-npu`; the stock driver cannot find the
  # compiler, the patched one loads it from its own store path. The service sets
  # this itself -- the session variable is for manual runs.
  environment.sessionVariables.ZE_ENABLE_ALT_DRIVERS = "${lib.getLib pkgs-npu.intel-npu-driver}/lib/libze_intel_npu.so";

  # The daemons of the hosts that build here (modules/nixos/base/remote-builders.nix).
  users.users.root.openssh.authorizedKeys.keys = myvars.remoteBuilderClientKeys;

  # systemd-journal - cap disk usage
  # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
  services.journald.settings.Journal = {
    SystemMaxUse = "10G";
    RuntimeMaxUse = "256M";
  };

  networking = {
    inherit hostName;

    # off: this host uses networkd (below).
    networkmanager.enable = false;
    useDHCP = false;
  };

  # A `boot.kernel.sysctl` that disabled IPv6 was removed on 2026-10-14: networkd
  # re-enables it on the wired link for the `DHCP = "ipv6"`/`IPv6AcceptRA` settings
  # below, so it never applied and the AAAA attempt already fails at once (WA-034).

  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Predictable names follow the PCIe topology, so match the `en*` prefix instead of
  # a name; one wired port, so one link.
  systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "en*" ];
    networkConfig = {
      Address = [
        ipv4WithMask
      ];
      # DNS goes to the proxy gateway, which resolves through the proxy;
      # `nameservers` is the plain upstream-DNS alternative.
      # DNS = nameservers;
      DNS = [ proxyGateway ];
      DHCP = "ipv6"; # enable DHCPv6 only, so we can get a GUA.
      IPv6AcceptRA = true; # for Stateless IPv6 Autoconfiguration (SLAAC)
      LinkLocalAddressing = "ipv6";
      # The RTL8125BG flaps carrier on link re-training; without this networkd
      # tears the static address and route down and the host drops off the LAN.
      IgnoreCarrierLoss = "10s";
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

  # This value determines the NixOS release from which the default
  # settings for stateful data (file locations, database versions) are taken.
  # It is the release this host was installed on.
  system.stateVersion = "26.11";
}
