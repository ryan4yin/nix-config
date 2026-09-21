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
        # regenerable, huge, or unsuitable for file-level backup
        #
        # the whole podman storage tree: the image layers are re-pullable, and
        # its storage DB is not consistent when copied from a running podman.
        # (uptime-kuma uses a named volume under here; its data is not wanted.)
        "var/lib/containers"
        "var/lib/microvms"
        "var/lib/libvirt"
        "nfs"
        "var/cache"
        "var/tmp"
        "var/log"
        "*.qcow2"
        # keys and credentials are never backed up
        "etc/agenix"
        "etc/ssh/ssh_host_*"
        "**/.ssh"
        "**/.gnupg"
        "**/.aws"
        "**/.config/gcloud"
      ]
      ++ cfg.exclude;

      timerConfig = {
        OnCalendar = "01:30";
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 2"
      ];
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
  };
}
