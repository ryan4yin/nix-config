# A restic backup of one host's data to a local repository (part 1 of the
# backup plan: the service state on the SSD -> the HDD under /data/backups).
#
# Part 2 (copying the critical snapshots from here to a cloud object store with
# `restic copy`) is a separate, later step. The other hosts are covered by
# btrbk, so only youko uses this.
{
  pkgs,
  # e.g. "/data/backups/restic/youko"
  repository,
  paths,
  # dump all postgres databases first, so the restore has a consistent SQL
  # artifact next to the (crash-consistent) data directory
  postgresDump ? false,
  ...
}:
{
  services.restic.backups.homelab = {
    inherit repository;
    initialize = true;
    passwordFile = "/etc/agenix/restic-password";
    paths = [ "/etc/agenix" ] ++ paths;

    # Regenerable, huge, or unsuitable for file-level backup:
    # - podman's overlay/image layers (re-pull the images); its named volumes
    #   under storage/volumes ARE kept
    # - microvms / libvirt: VM disk images (use app-level dumps instead)
    # - nfs: golden images exported to the cluster
    exclude = [
      "/persistent/var/lib/containers/storage/overlay"
      "/persistent/var/lib/containers/storage/overlay-layers"
      "/persistent/var/lib/containers/storage/overlay-images"
      "/persistent/var/lib/containers/storage/overlay-containers"
      "/persistent/var/lib/microvms"
      "/persistent/var/lib/libvirt"
      "/persistent/nfs"
      "/persistent/var/cache"
      "/persistent/var/tmp"
      "/persistent/var/log"
      "*.qcow2"
    ];

    timerConfig = {
      OnCalendar = "01:30";
      RandomizedDelaySec = "1h";
    };

    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 3"
      "--keep-monthly 3"
      "--keep-yearly 3"
    ];
  }
  // pkgs.lib.optionalAttrs postgresDump {
    backupPrepareCommand = ''
      ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql_16}/bin/pg_dumpall --clean \
        > /var/lib/postgresql/all-databases.sql
    '';
    backupCleanupCommand = "rm -f /var/lib/postgresql/all-databases.sql";
  };

  # the repository lives on the HDD (/data is `nofail`), so nothing else orders
  # the backup after it being mounted
  systemd.services.restic-backups-homelab.unitConfig.RequiresMountsFor = "/data/backups";
}
