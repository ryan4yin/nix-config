{
  # Reboot physical hosts after a hard freeze or kernel panic instead of waiting for a power cycle;
  # a host without a hardware watchdog only logs that /dev/watchdog is missing.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
  boot.kernel.sysctl."kernel.panic" = 10; # seconds; the default 0 hangs forever
}
