{
  pkgs,
  ...
}:
let
  # The restic REST server store, and a directory on the sibling @snapshots
  # subvolume (same btrfs pool), so the snapshots are real subvolumes the
  # desktop has no path to.
  source = "/data/backups";
  snapshotRoot = "/data/apps-snapshots/restic";
  keepDays = 14;
in
{
  # The REST server is deliberately not append-only: the desktop holds both the
  # data and its repository password and still needs to run retention. That
  # leaves the repository deletable by anyone holding the desktop's REST
  # credentials. A read-only snapshot the desktop cannot reach makes a
  # `forget --prune` recoverable without giving up retention.
  systemd.tmpfiles.rules = [
    "d ${snapshotRoot} 0700 root root -"
  ];

  systemd.services.restic-server-snapshot = {
    description = "Read-only btrfs snapshot of the restic server store";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    path = [
      pkgs.btrfs-progs
      pkgs.coreutils
      pkgs.findutils
    ];
    script = ''
      set -euo pipefail
      stamp=$(date +%Y%m%d%H%M%S)
      btrfs subvolume snapshot -r ${source} ${snapshotRoot}/backups.$stamp
      # Drop snapshots older than ${toString keepDays} days. The desktop cannot
      # reach this tree, so it cannot shorten the window.
      find ${snapshotRoot} -mindepth 1 -maxdepth 1 -type d -mtime +${toString keepDays} -print0 |
        xargs -0 -r -n1 btrfs subvolume delete
    '';
    unitConfig.RequiresMountsFor = source;
  };

  systemd.timers.restic-server-snapshot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
