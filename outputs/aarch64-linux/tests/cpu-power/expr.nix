{
  lib,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.shoukei-niri.config;
in
{
  governor = cfg.powerManagement.cpuFreqGovernor;
  noTuned = lib.all (host: !host.config.services.tuned.enable) (
    builtins.attrValues outputs.nixosConfigurations
  );
  noFrequencyCaps =
    cfg.powerManagement.cpufreq.min == null && cfg.powerManagement.cpufreq.max == null;
  batteryReporting = cfg.services.upower.enable;
}
