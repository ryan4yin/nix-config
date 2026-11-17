{
  # Headless physical servers: turn silent kernel failures into panics, so efi_pstore keeps the
  # dmesg and kernel.panic reboots. Desktops stay out: a GPU driver oops would drop the session.
  # hung_task_panic stays off: a stalled USB disk would trip it.
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 1;
    "kernel.softlockup_panic" = 1;
    "kernel.hardlockup_panic" = 1;
    "kernel.panic_on_rcu_stall" = 1;
  };
  # Keep the panic text visible on an attached monitor.
  boot.kernelParams = [ "consoleblank=0" ];
  # A failed mount continues the boot with SSH instead of waiting on a console sulogin.
  systemd.enableEmergencyMode = false;
}
