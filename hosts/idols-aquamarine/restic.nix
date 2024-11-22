{pkgs, ...}: let
  passwordFile = "/etc/agenix/restic-password";
  sshKeyPath = "/etc/agenix/ssh-key-for-restic-backup";
  rcloneConfigFile = "/etc/agenix/rclone-conf-for-restic-backup";
in {
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/backup/restic.nix
  services.restic.backups = {
    homelab-backup = {
      inherit passwordFile;
      initialize = true; # Initialize the repository if it doesn't exist.
      repository = "rclone:smb-downloads:/Downloads/kubevirt-backup/"; # backup to a rclone remote

      # rclone related
      # rcloneOptions = {
      #   bwlimit = "100M";  # Limit the bandwidth used by rclone.
      # };
      inherit rcloneConfigFile;

      # Which local paths to backup, in addition to ones specified via `dynamicFilesFrom`.
      paths = [
        "/tmp/restic-backup-temp"
      ];
      #
      # A script that produces a list of files to back up.  The
      # results of this command are given to the '--files-from'
      # option. The result is merged with paths specified via `paths`.
      # dynamicFilesFrom = "find /home/matt/git -type d -name .git";
      #
      # Patterns to exclude when backing up. See
      #   https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files
      # for details on syntax.
      exclude = [];

      # A script that must run before starting the backup process.
      backupPrepareCommand = ''
        ${pkgs.nushell}/bin/nu -c '
          let kubevirt_nodes = [
            "kubevirt-shoryu"
            "kubevirt-shushou"
            "kubevirt-youko"
          ]

          kubevirt_nodes | each {|it|
            rsync -avz \
            -e "ssh -i ${sshKeyPath}"  \
            $"($it):/perissitent/" $"/tmp/restic-backup-temp/($it)"
          }
        '
      '';
      # A script that must run after finishing the backup process.
      backupCleanupCommand = "rm -rf /tmp/restic-backup-temp";

      # Extra extended options to be passed to the restic --option flag.
      # extraOptions = [];

      # Extra arguments passed to restic backup.
      # extraBackupArgs = [
      #   "--exclude-file=/etc/restic/excludes-list"
      # ];

      # repository = "/mnt/backup-hdd"; # backup to a local directory
      # When to run the backup. See {manpage}`systemd.timer(5)` for details.
      timerConfig = {
        OnCalendar = "01:30";
        RandomizedDelaySec = "1h";
      };
      # A list of options (--keep-* et al.) for 'restic forget --prune',
      # to automatically prune old snapshots.
      # The 'forget' command is run *after* the 'backup' command, so
      # keep that in mind when constructing the --keep-* options.
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 3"
        "--keep-monthly 3"
        "--keep-yearly 3"
      ];
    };
  };
}
