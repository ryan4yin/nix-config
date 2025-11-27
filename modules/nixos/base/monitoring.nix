{
  # enable the node exporter on all nixos hosts
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/monitoring/prometheus/exporters/node.nix
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
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
}
