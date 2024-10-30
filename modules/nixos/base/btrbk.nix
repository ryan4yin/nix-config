{
  # ==================================================================
  #
  # Tool for creating snapshots and remote backups of btrfs subvolumes
  #   https://github.com/digint/btrbk
  #
  # Usage:
  #   1. btrbk will create snapshots on schedule
  #   2. we can use `btrbk run` command to create a backup manually
  #
  # How to restore a snapshot:
  #   1. Find the snapshot you want to restore in /snapshots
  #   2. Use `btrfs subvol delete /btr_pool/@persistent` to delete the current subvolume
  #   3. Use `btrfs subvol snapshot /snapshots/2021-01-01 /btr_pool/@persistent` to restore the snapshot
  #   4. reboot the system or remount the filesystem to see the changes
  #
  # ==================================================================

  services.btrbk.instances.btrbk = {
    # How often this btrbk instance is started. See systemd.time(7) for more information about the format.
    onCalendar = "Tue,Sat *-*-* 3:45:20";
    settings = {
      # how to prune local snapshots:
      # 1. keep daily snapshots for xx days
      snapshot_preserve = "7d";
      # 2. keep all snapshots for 2 days, no matter how frequently you (or your cron job) run btrbk
      snapshot_preserve_min = "2d";

      # hot to prune remote incremental baqckups:
      # keep daily backups for 9 days, weekly backups for 4 weeks, and monthly backups for 2 months
      target_preserve = "9d 4w 2m";
      target_preserve_min = "no";

      volume = {
        "/btr_pool" = {
          subvolume = {
            "@persistent" = {
              snapshot_create = "always";
            };
          };

          # backup to a remote server or a local directory
          # its prune policy is defined by `target_preserve` and `target_preserve_min`
          # target = "/snapshots";
        };
      };
    };
  };
}
