{
  config,
  lib,
  myvars,
  ...
}:
let
  # Exporters bind to this host's static LAN IPv4 (the same address
  # VictoriaMetrics scrapes), so the socket exists only on the LAN interface —
  # defence in depth behind the firewall allowlist. Hosts without a static LAN
  # address (laptops like shoukei, DHCP VMs like akane) run no exporters.
  lanAddr = myvars.networking.hostsAddr.${config.networking.hostName}.ipv4 or null;
in
{
  # enable the node exporter on all nixos hosts
  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/monitoring/prometheus/exporters/node.nix
  services.prometheus.exporters.node = lib.mkIf (lanAddr != null) {
    enable = true;
    listenAddress = lanAddr;
    port = 9100;
    # There're already a lot of collectors enabled by default
    # https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default
    enabledCollectors = [
      "systemd"
      "logind"
    ];

    # use either enabledCollectors or disabledCollectors
    # disabledCollectors = [];

    extraFlags = [
      # Exclude pseudo/ephemeral FS:
      #   - /proc, /sys: kernel pseudo-FS, always size 0
      #   - /dev: tmpfs/devices, not meaningful for disk usage
      # Exclude system/runtime tmp dirs:
      #   - /run/credentials/... → systemd service secrets (strict perms)
      #   - /run/user/... → per-user tmpfs (0700, IPC sockets, not storage)
      # Exclude container/runtime mounts:
      #   - /var/lib/docker/, /var/lib/containers/ and /var/lib/kubelet/ → too much overlay/tmpfs mounts,
      #     often EACCES (strict perms, namespaces) → false alerts
      # Exclude user bind mounts:
      #   - /home/ryan/.+ → bind-mounted from /persistent (NixOS tmpfs-root setup),
      #     monitoring /persistent is sufficient
      # Note: ^(/|/persistent/) prefix ensures both root-level and
      #       /persistent-prefixed paths (used in NixOS's tmpfs-as-root setup) are excluded.
      "--collector.filesystem.mount-points-exclude=^(/|/persistent/)(dev|proc|sys|run/credentials/.+|run/user/.+|var/lib/docker/.+|var/lib/containers/.+|var/lib/kubelet/.+|home/ryan/.+)($|/)"
    ];
  };

  # Drive SMART health (wear, spare, media errors, temperature, bytes written)
  # on physical hosts. node_exporter's nvme collector only exposes
  # node_nvme_info and namespace capacity, NOT SMART health, so this is the only
  # source of SSD lifespan data. `hardwareTools` is off on MicroVM/QEMU guests,
  # which have no physical disks to inspect.
  services.prometheus.exporters.smartctl =
    lib.mkIf (lanAddr != null && config.modules.hardwareTools.enable)
      {
        enable = true;
        listenAddress = lanAddr;
        port = 9633;
        maxInterval = "60s";
      };

  # LAN-bound exporters race networkd's address assignment at boot; without
  # ordering they trip the start limit (seen on ai). wait-online is best-effort
  # (120s timeout), so also retry patiently.
  systemd.services = lib.mkIf (lanAddr != null) (
    lib.genAttrs
      (
        [ "prometheus-node-exporter" ]
        ++ lib.optionals config.modules.hardwareTools.enable [ "prometheus-smartctl-exporter" ]
      )
      (_: {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          RestartSec = "10s";
          StartLimitIntervalSec = 0;
        };
      })
  );
}
