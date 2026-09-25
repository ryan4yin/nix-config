{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.restic-backup;

  # A short-lived, read-only btrfs snapshot taken by the backup itself, so the
  # backup is a consistent point-in-time (a live copy of, say, a running
  # postgres data directory is only crash-consistent). It is deleted right
  # after, so it is not a second backup - just a consistency step.
  snapshotPath = "${builtins.dirOf cfg.snapshotSource}/@restic-snapshot";
in
{
  # ==================================================================
  #
  # A restic backup to a LOCAL repository (part 1 of the backup plan).
  #
  # Part 2 (copying the critical snapshots to a cloud object store with
  # `restic copy`) is a later step. btrbk keeps making the cheap local btrfs
  # snapshots for rollbacks; off-host copies are restic's job (restic can
  # exclude the regenerable bulk at the file level).
  #
  # Keys and credentials are NEVER included: restic's own password lives in
  # /etc/agenix, so backing that up would store the repository's password
  # inside the repository.
  #
  # ==================================================================
  options.modules.restic-backup = {
    enable = lib.mkEnableOption "a restic backup (local repository)";

    repository = lib.mkOption {
      type = lib.types.str;
      example = "/data/backups/restic/youko";
      description = "Restic repository, e.g. a path under a mounted backup disk.";
    };

    snapshotSource = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/btr_pool/@persistent";
      description = ''
        btrfs subvolume to back up through a short-lived read-only snapshot.
        When null, `paths` is backed up directly.
      '';
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths to back up (used when {option}`snapshotSource` is null).";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra exclude patterns, on top of the built-in ones.";
    };

    requiresMountsFor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Mount point the repository lives on, when it is a `nofail` mount: the
        backup is then ordered after that mount instead of running against a
        not-yet-mounted directory.
      '';
    };

    excludeLargerThan = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "500M";
      description = ''
        Skip any file larger than this (restic's `--exclude-larger-than`). A size
        cap is more reliable than guessing file types when the tree contains
        large re-downloadable artifacts.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = config.age.secrets."restic-rest-credentials".path;
      description = ''
        systemd `EnvironmentFile` with restic environment variables. Needed for
        a `rest:` repository, whose credentials are environment-only
        (`RESTIC_REST_USERNAME` / `RESTIC_REST_PASSWORD`) and must not appear in
        the repository URL.
      '';
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "01:30";
      description = ''
        systemd calendar expression for the backup timer. Give every host its
        own slot rather than relying on the random delay: a client's off-host
        push, the backup server's own run and btrbk (Tue/Sat 03:45:20 by
        default) all contend for the same disks otherwise.
      '';
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Extra random delay on top of {option}`onCalendar`, to smooth load.";
    };

    alertManagerUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://alertmanager.writefor.fun";
      description = ''
        Alertmanager to POST a failure alert to (`/api/v2/alerts`). youko routes
        anything above info severity to telegram, so a failed backup is not
        silent.
      '';
    };

    pruneOpts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 2"
      ];
      description = ''
        Retention passed to `restic forget --prune`. Leave it empty when the
        repository is an append-only server: that server rejects deletion, so
        the client cannot forget or prune (the backup would otherwise fail
        after uploading).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.homelab = {
      inherit (cfg) repository;
      initialize = true;
      # take the path from agenix itself instead of hardcoding its secretsDir
      passwordFile = config.age.secrets."restic-password".path;

      paths = if cfg.snapshotSource != null then [ snapshotPath ] else cfg.paths;

      # Relative to the backed-up tree, so they work for both the snapshot and
      # a direct path.
      exclude = [
        # Universal: keys and credentials are never backed up, on any host.
        # (restic's own password lives in /etc/agenix, so backing that up would
        # store the repository's password inside the repository.)
        #
        # Host-specific excludes (regenerable bulk, VM images, ...) belong in
        # the host's own config.
        "etc/agenix"
        "etc/ssh/ssh_host_*"
        "**/.ssh"
        "**/.gnupg"
        "**/.aws"
        "**/.config/gcloud"
      ]
      ++ cfg.exclude;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };

      inherit (cfg) pruneOpts;
    }
    // lib.optionalAttrs (cfg.excludeLargerThan != null) {
      extraBackupArgs = [
        "--exclude-larger-than"
        cfg.excludeLargerThan
      ];
    }

    // lib.optionalAttrs (cfg.environmentFile != null) {
      inherit (cfg) environmentFile;
    }

    // lib.optionalAttrs (cfg.snapshotSource != null) {
      backupPrepareCommand = ''
        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r ${cfg.snapshotSource} ${snapshotPath}
      '';
      backupCleanupCommand = ''
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete ${snapshotPath}
      '';
    };

    systemd.services.restic-backups-homelab.unitConfig =
      lib.optionalAttrs (cfg.requiresMountsFor != null)
        {
          RequiresMountsFor = cfg.requiresMountsFor;
        };

    # A failed backup must not be silent: report it to alertmanager, which
    # routes anything above info severity to telegram.
    systemd.services.restic-backups-homelab.onFailure = [ "restic-backup-notify.service" ];

    systemd.services.restic-backup-notify = {
      description = "Report a failed restic backup";
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.curl}/bin/curl -sS -o /dev/null -X POST ${cfg.alertManagerUrl}/api/v2/alerts \
          -H 'Content-Type: application/json' \
          --data "[{ \
            \"labels\": { \"alertname\": \"ResticBackupFailed\", \"severity\": \"critical\", \"host\": \"${config.networking.hostName}\" }, \
            \"annotations\": { \"summary\": \"restic backup failed on ${config.networking.hostName}\", \"description\": \"journalctl -u restic-backups-homelab\" } \
          }]"
      '';
    };
  };
}
