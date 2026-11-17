{ pkgs, ... }:
{
  # Headless physical servers: turn silent kernel failures into panics, so efi_pstore keeps the
  # dmesg and kernel.panic reboots. Desktops stay out: a GPU driver oops would drop the session.
  # hung_task_panic stays off: a stalled USB disk would trip it.
  # Armed 5 minutes after boot, so an oops during boot cannot loop panic-reboots before SSH is up.
  systemd.services.panic-on-lockup = {
    description = "Panic on kernel oops, lockup or RCU stall";
    path = [ pkgs.procps ];
    serviceConfig.Type = "oneshot";
    script = ''
      sysctl -w kernel.panic_on_oops=1
      sysctl -w kernel.softlockup_panic=1
      sysctl -w kernel.hardlockup_panic=1
      sysctl -w kernel.panic_on_rcu_stall=1
    '';
  };
  systemd.timers.panic-on-lockup = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnBootSec = "5min";
  };
  # Keep the panic text visible on an attached monitor.
  boot.kernelParams = [ "consoleblank=0" ];
  # A failed mount continues the boot with SSH instead of waiting on a console sulogin.
  systemd.enableEmergencyMode = false;
}
