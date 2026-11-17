{
  # Reboot physical hosts after a hard freeze or kernel panic instead of waiting for a power cycle;
  # a host without a hardware watchdog only logs that /dev/watchdog is missing.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
  boot.kernel.sysctl."kernel.panic" = 20; # seconds; the default 0 hangs forever
  # A hard reset keeps only what journald fsynced; the default 5min loses the lead-up to a freeze.
  services.journald.settings.Journal.SyncIntervalSec = "5s";
}
