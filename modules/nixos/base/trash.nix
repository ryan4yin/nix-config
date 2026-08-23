{
  # ==================================================================
  #
  # Trash retention cleanup (nixpkgs `trash-cli`)
  #   https://github.com/andreafrancia/trash-cli
  #
  # On a tmpfs root with persistent dirs bind-mounted in, the trash
  # crate (nushell `rm --trash`, GUI file managers) scatters items into
  # per-mount .Trash-$uid dirs that file managers never show. This timer
  # purges trash items older than RETENTION_DAYS across the home trash
  # and all mount points.
  #
  # Usage:
  #   trash-list             # view items in all trash dirs
  #   trash-restore <file>   # restore an item
  #   trash-rm <file>        # remove a single item from the trash
  #   trash-empty 30 -f      # run the retention purge manually
  #
  # ==================================================================

  myvars,
  pkgs,
  ...
}:
let
  retentionDays = 30;
in
{
  systemd.services.trash-empty = {
    description = "Purge trash items older than ${toString retentionDays} days";
    script = ''
      ${pkgs.trash-cli}/bin/trash-empty ${toString retentionDays} -f
    '';
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = myvars.username;
      Environment = [
        "HOME=/home/${myvars.username}"
        "XDG_DATA_HOME=/home/${myvars.username}/.local/share"
      ];
    };
  };

  systemd.timers.trash-empty = {
    description = "Timer for the trash-empty service";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "15min";
    };
  };
}
