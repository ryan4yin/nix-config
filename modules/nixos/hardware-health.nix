{ lib, ... }:
{
  # Monthly scrub of every btrfs filesystem; errors show up in node_btrfs_device_errors_total.
  # Start between 04:00 and 05:00, after the 01:30-03:45 backup window (docs/BACKUP.md):
  # nixpkgs' AccuracySec of 1d could otherwise place it anywhere in the day.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "*-*-01 04:00:00";
  };
  systemd.timers."btrfs-scrub@".timerConfig.AccuracySec = lib.mkForce "1h";

  # Record machine-check, PCIe AER and memory errors; exported to VictoriaMetrics by
  # modules/nixos/base/monitoring.nix. Its database lives in the preserved /var/lib.
  hardware.rasdaemon.enable = true;
}
