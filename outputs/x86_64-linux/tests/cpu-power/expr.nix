{
  lib,
  outputs,
  ...
}:
let
  configs = outputs.nixosConfigurations;
  physicalHosts = [
    "ai-niri"
    "aquamarine"
    "shoryu"
    "shushou"
    "youko"
  ];
  serverHosts = [
    "aquamarine"
    "shoryu"
    "shushou"
    "youko"
  ];
in
{
  governors = lib.genAttrs physicalHosts (
    name: configs.${name}.config.powerManagement.cpuFreqGovernor
  );
  noTuned = lib.all (host: !host.config.services.tuned.enable) (builtins.attrValues configs);
  noEeeWorkaround = lib.all (host: !(host.config.systemd.services ? disable-eee)) (
    builtins.attrValues configs
  );
  noFrequencyCaps = lib.all (
    name:
    let
      cfg = configs.${name}.config.powerManagement;
    in
    cfg.cpufreq.min == null && cfg.cpufreq.max == null
  ) physicalHosts;
  guestsHaveNoCpuPolicy = lib.all (name: !(configs.${name}.config.systemd.services ? cpufreq)) (
    lib.subtractLists physicalHosts (builtins.attrNames configs)
  );
  serverRaplEnabled = lib.genAttrs serverHosts (
    name:
    configs.${name}.config.modules.powerMonitoring.enable
    && builtins.elem "rapl" configs.${name}.config.services.prometheus.exporters.node.enabledCollectors
    && lib.hasInfix "chgrp rapl" configs.${name}.config.services.udev.extraRules
  );
  serverRaplReaderOnly = lib.all (
    name:
    builtins.elem "rapl" configs.${name}.config.users.users.node-exporter.extraGroups
    && !(builtins.elem "rapl" (configs.${name}.config.users.users.ryan.extraGroups or [ ]))
  ) serverHosts;
  desktopRaplDisabled =
    !configs.ai-niri.config.modules.powerMonitoring.enable
    && !(builtins.elem "rapl" configs.ai-niri.config.services.prometheus.exporters.node.enabledCollectors)
    && !(lib.hasInfix "chgrp rapl" configs.ai-niri.config.services.udev.extraRules);
  guestsHaveNoRapl = lib.all (
    name: !(lib.hasInfix "chgrp rapl" configs.${name}.config.services.udev.extraRules)
  ) (lib.subtractLists physicalHosts (builtins.attrNames configs));
  desktopBatteryReporting = configs.ai-niri.config.services.upower.enable;
}
