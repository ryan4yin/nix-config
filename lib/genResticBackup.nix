# A restic backup for one of the physical hosts. Each host backs up its own
# data directly to the rclone/SMB remote (no rsync aggregation): that avoids the
# tmpfs-sized temp directory, keeps each host's failure visible, and lets restic
# deduplicate against the previous run.
#
# Usage: mylib.genResticBackup { inherit pkgs hostName; paths = [ ... ]; }
{
  pkgs,
  hostName,
  # host-specific paths (the shared ones below are always included)
  paths ? [ ],
  # dump all postgres databases before the backup, so the restore has a
  # consistent SQL artifact next to the (crash-consistent) data directory
  postgresDump ? false,
  ...
}:
{
  services.restic.backups.homelab = {
    initialize = true;
    passwordFile = "/etc/agenix/restic-password";
    rcloneConfigFile = "/etc/agenix/rclone-conf-for-restic-backup";
    # one repository per host: independent locks and retention
    repository = "rclone:smb-downloads:/Downloads/homelab-backup/${hostName}";

    paths = [
      "/etc/agenix"
      "/etc/ssh"
      "/persistent/etc/rancher" # k3s token
    ]
    ++ paths;

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

    # don't prune on the remote every day (it takes an exclusive lock)
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
}
