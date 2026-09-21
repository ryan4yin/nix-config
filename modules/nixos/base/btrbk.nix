{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.btrbk;
in
{
  # ==================================================================
  #
  # btrbk - scheduled LOCAL btrfs snapshots.
  #   https://github.com/digint/btrbk
  #
  # Snapshots are created in `snapshotDir` (relative to the btrfs top-level
  # subvolume mounted at `volume`) and pruned by `snapshot_preserve`. With the
  # defaults they land in the @snapshots subvolume (mounted at /snapshots):
  #
  #   /btr_pool/@snapshots/@persistent.<timestamp>
  #
  # These are same-filesystem snapshots: they protect against accidental
  # deletion and bad edits, NOT against disk loss. Off-host copies are handled
  # by restic (lib/genResticBackup.nix), which can exclude the regenerable bulk
  # at the file level; btrbk works at the subvolume level, so a `target` would
  # also ship podman's overlay storage and the VM disk images. Set `target`
  # (plus `services.btrbk.sshAccess` on the receiving host) only if you want
  # that.
  #
  # The host MUST mount the btrfs top-level subvolume (subvolid=5) at `volume`;
  # this is enforced by an assertion so a missing mount fails evaluation instead
  # of failing silently at 3am.
  #
  # Restore a snapshot (offline; stop writers first):
  #   1. btrfs subvolume delete /btr_pool/@persistent
  #   2. btrfs subvolume snapshot /btr_pool/@snapshots/@persistent.<timestamp> \
  #        /btr_pool/@persistent
  #   3. reboot, or remount /persistent, to pick up the restored subvolume.
  #
  # ==================================================================
  options.modules.btrbk = {
    enable = lib.mkEnableOption "scheduled btrfs snapshots via btrbk";

    volume = lib.mkOption {
      type = lib.types.str;
      default = "/btr_pool";
      description = "Mount point of the btrfs top-level subvolume (subvolid=5).";
    };

    subvolume = lib.mkOption {
      type = lib.types.str;
      default = "@persistent";
      description = "Source subvolume to snapshot, relative to {option}`modules.btrbk.volume`.";
    };

    snapshotDir = lib.mkOption {
      type = lib.types.str;
      default = "@snapshots";
      description = "Directory the snapshots are created in, relative to {option}`modules.btrbk.volume`.";
    };

    target = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional off-host btrbk backup target (`target` in btrbk.conf). When
        null, only local snapshots are kept, which does not protect against
        disk loss.
      '';
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "Tue,Sat *-*-* 3:45:20";
      description = "systemd calendar expression for the snapshot timer.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.volume config.fileSystems;
        message = "modules.btrbk: no filesystem is mounted at `${cfg.volume}`; mount the btrfs top-level subvolume (subvolid=5) there so btrbk can snapshot `${cfg.volume}/${cfg.subvolume}`.";
      }
    ];

    services.btrbk.instances.btrbk = {
      onCalendar = cfg.onCalendar;
      settings = {
        # keep daily snapshots for 7 days, and always keep 2 days worth.
        snapshot_preserve = "7d";
        snapshot_preserve_min = "2d";

        # retention for an optional off-host target.
        target_preserve = "9d 4w 2m";
        target_preserve_min = "no";

        volume.${cfg.volume} = {
          snapshot_dir = cfg.snapshotDir;
          subvolume.${cfg.subvolume} = {
            snapshot_create = "always";
          };
        }
        // lib.optionalAttrs (cfg.target != null) {
          target = cfg.target;
        };
      };
    };
  };
}
