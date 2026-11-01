{
  pkgs,
  ...
}:
{
  # Ad-hoc CPU idle-power diagnostics: package power, C-state residency and
  # wakeup attribution. Long-term RAPL export lives in the shared
  # modules/nixos/base/power-monitoring.nix module.
  environment.systemPackages = [
    pkgs.linuxPackages_latest.cpupower
    pkgs.linuxPackages_latest.turbostat
    pkgs.powertop
  ];

  # `powerManagement.cpuFreqGovernor = "powersave"` on x86 only selects the
  # cpufreq governor. Intel P-state has a second knob, EPP, which biases the
  # hardware between performance and power before the governor acts. Keep the
  # existing powersave governor, but use the power-oriented EPP for this host.
  #
  # `boot.kernel.sysfs` is NixOS's native, declarative interface for sysfs
  # attributes. It waits for the cpufreq attribute and writes it idempotently,
  # so no private cpupower systemd service is needed.
  boot.kernel.sysfs.devices.system.cpu."cpu[0-9]*".cpufreq.energy_performance_preference =
    "balance_power";
}
