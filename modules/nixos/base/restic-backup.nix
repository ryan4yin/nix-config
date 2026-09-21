{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.restic-backup;
in
{
  # ==================================================================
  #
  # A restic backup to a LOCAL repository (part 1 of the backup plan).
  #
  # Part 2 (copying the critical snapshots to a cloud object store with
  # `restic copy`) is a later step. btrbk keeps making the cheap local btrfs
  # snapshots; it works at the subvolume level, so off-host copies are restic's
  # job (restic can exclude the regenerable bulk at the file level).
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

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths to back up.";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Patterns to exclude, in addition to the keys/credentials below.";
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

    postgresDump = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Dump all postgres databases before the backup, so the restore has a
        consistent SQL artifact next to the (crash-consistent) data directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.homelab = {
      inherit (cfg) repository;
      initialize = true;
      passwordFile = "/etc/agenix/restic-password";
      inherit (cfg) paths;
      exclude = [
        # regenerable, huge, or unsuitable for file-level backup
        #
        # the whole podman storage tree: the image layers are re-pullable, and
        # its storage DB is not consistent when backed up from a running podman.
        # (uptime-kuma uses a named volume under here; its data is intentionally
        # not preserved.)
        "/persistent/var/lib/containers"
        "/persistent/var/lib/microvms"
        "/persistent/var/lib/libvirt"
        "/persistent/nfs"
        "/persistent/var/cache"
        "/persistent/var/tmp"
        "/persistent/var/log"
        "*.qcow2"
        # keys and credentials are never backed up
        "/persistent/etc/agenix"
        "/persistent/etc/ssh/ssh_host_*"
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
    // lib.optionalAttrs cfg.postgresDump {
      backupPrepareCommand = ''
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql_16}/bin/pg_dumpall --clean \
          > /var/lib/postgresql/all-databases.sql
      '';
      backupCleanupCommand = "rm -f /var/lib/postgresql/all-databases.sql";
    };

    systemd.services.restic-backups-homelab.unitConfig =
      lib.optionalAttrs (cfg.requiresMountsFor != null)
        {
          RequiresMountsFor = cfg.requiresMountsFor;
        };
  };
}
