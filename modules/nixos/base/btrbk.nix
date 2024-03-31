{
  # Tool for creating snapshots and remote backups of btrfs subvolumes
  # https://github.com/digint/btrbk
  services.btrbk.instances.btrbk = {
    # How often this btrbk instance is started. See systemd.time(7) for more information about the format.
    onCalendar = "daily";
    settings = {
      # keep daily snapshots for 14 days
      snapshot_preserve = "14d";
      # keep all snapshots for 2 days, no matter how frequently you (or your cron job) run btrbk
      snapshot_preserve_min = "2d";
      volume = {
        "/btr_pool" = {
          subvolume = {
            "@persistent" = {
              snapshot_create = "always";
            };
          };
          target = "/snapshots";
        };
      };
    };
  };
}
