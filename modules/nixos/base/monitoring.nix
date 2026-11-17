{
  config,
  lib,
  pkgs,
  inputs,
  mylib,
  myvars,
  ...
}:
let
  # Exporters bind to this host's static LAN IPv4 (the same address
  # VictoriaMetrics scrapes), so the socket exists only on the LAN interface —
  # defence in depth behind the firewall allowlist. Hosts without an always-on
  # static LAN address (the `homeOnly` laptop, DHCP VMs like akane) run no
  # exporters.
  hostAddr = myvars.networking.hostsAddr.${config.networking.hostName} or { };
  lanAddr = if hostAddr.homeOnly or false then null else hostAddr.ipv4 or null;

  # Where node_exporter's textfile collector reads `*.prom` files. Keep in sync
  # with modules/nixos/base/restic-backup.nix, which writes the last successful
  # backup timestamp here.
  textfileDir = "/var/lib/node_exporter/textfile_collector";

  lanExporters = lib.filterAttrs (_: cfg: cfg.enable) {
    inherit (config.services.prometheus.exporters) node smartctl nvidia-gpu;
  };

  # Deploy-state metrics are published by physical hosts only (hardwareTools is
  # off on VM guests).
  publishDeployState =
    config.services.prometheus.exporters.node.enable && config.modules.hardwareTools.enable;

  # nixpkgs only: any other input would rebuild every host whenever it moves.
  flakeInputsProm = pkgs.writeText "flake-inputs.prom" ''
    # HELP flake_input_last_modified Commit time of a flake input of the running generation.
    # TYPE flake_input_last_modified gauge
    flake_input_last_modified{input="nixpkgs",rev="${inputs.nixpkgs.rev}"} ${toString inputs.nixpkgs.lastModified}
  '';
in
{
  # node_exporter on every host that has a static LAN IPv4 (see `lanAddr` above)
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
      # Metrics that no exporter can produce itself, e.g. the timestamp of the
      # last successful restic backup (written by restic-backup.nix).
      "textfile"
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
      # The collector does not create its directory, and a missing one logs an
      # error on every scrape.
      "--collector.textfile.directory=${textfileDir}"
      "--web.systemd-socket"
    ];
  };

  # Created here so the textfile collector has somewhere to read from before
  # the first successful backup writes its metric.
  systemd.tmpfiles.rules = lib.mkIf (lanAddr != null) (
    [ "d ${textfileDir} 0755 root root - -" ]
    ++ lib.optional publishDeployState "L+ ${textfileDir}/flake-inputs.prom - - - - ${flakeInputsProm}"
  );

  # node_reboot_required for the HostRequiresReboot alert. Compare against the
  # system profile, not /run/current-system: a `boot` deploy only moves the
  # profile. Same comparison as nixpkgs' system.autoUpgrade.allowReboot.
  systemd.services.node-reboot-required = lib.mkIf publishDeployState {
    description = "Report whether the next boot changes the kernel, initrd or modules";
    serviceConfig = mylib.systemdHardening.mkDefaults mylib.systemdHardening.service // {
      Type = "oneshot";
      ReadWritePaths = [ textfileDir ];
    };
    path = [ pkgs.coreutils ];
    script = ''
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
      required=0
      if [ "$booted" != "$built" ]; then
        required=1
      fi
      {
        echo '# HELP node_reboot_required 1 if the system profile boots another kernel, initrd or kernel modules.'
        echo '# TYPE node_reboot_required gauge'
        echo "node_reboot_required $required"
      } > ${textfileDir}/reboot-required.prom.tmp
      mv -f ${textfileDir}/reboot-required.prom.tmp ${textfileDir}/reboot-required.prom
    '';
  };
  systemd.timers.node-reboot-required = lib.mkIf publishDeployState {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
    };
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
        extraFlags = [ "--web.systemd-socket" ];
      };

  # MCE, AER and memory-controller error counts from rasdaemon's database, on
  # hosts that run rasdaemon.
  services.prometheus.exporters.rasdaemon =
    lib.mkIf (lanAddr != null && config.hardware.rasdaemon.enable)
      {
        enable = true;
        listenAddress = lanAddr;
        port = 10029;
        # No flags: each flag turns off one of the default aer/mce/mc collectors
        # (WA-053 in docs/WORKAROUNDS.md).
        enabledCollectors = [ ];
      };
  # This Python exporter cannot take a systemd socket, so it binds the LAN
  # address itself and retries until the address exists and rasdaemon has
  # created its database.
  systemd.services.prometheus-rasdaemon-exporter =
    lib.mkIf config.services.prometheus.exporters.rasdaemon.enable
      {
        after = [ "rasdaemon.service" ];
        serviceConfig.RestartSec = "5s";
      };

  # Socket activation with FreeBind: the LAN address may not exist yet at boot.
  systemd.sockets = lib.mkIf (lanAddr != null) (
    lib.mapAttrs' (
      name: cfg:
      lib.nameValuePair "prometheus-${name}-exporter" {
        wantedBy = [ "sockets.target" ];
        # nixpkgs also starts the service from multi-user.target; requiring the
        # socket (which systemd orders first) keeps a switch from starting it bare.
        requiredBy = [ "prometheus-${name}-exporter.service" ];
        listenStreams = [ "${cfg.listenAddress}:${toString cfg.port}" ];
        socketConfig.FreeBind = true;
      }
    ) lanExporters
  );
  services.prometheus.exporters.nvidia-gpu.extraFlags = lib.mkIf (lanAddr != null) [
    "--web.systemd-socket"
  ];
}
