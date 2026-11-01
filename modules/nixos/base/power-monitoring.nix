{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.powerMonitoring;
in
{
  options.modules.powerMonitoring.enable = lib.mkEnableOption ''
    Export RAPL CPU energy counters through node_exporter and allow only the
    exporter to read them.

    This weakens the kernel's root-only energy_uj permission for local RAPL
    side-channel reasons, so it is opt-in and must stay disabled on desktops.
  '';

  config =
    lib.mkIf (cfg.enable && config.modules.hardwareTools.enable && pkgs.stdenv.hostPlatform.isx86)
      {
        services.prometheus.exporters.node.enabledCollectors = [ "rapl" ];

        # Only node_exporter needs the counters. Do not grant the interactive
        # user or the world read access: both would expose a local RAPL
        # side-channel to desktop sessions and unprivileged processes.
        users.groups.rapl = lib.mkIf config.services.prometheus.exporters.node.enable { };
        users.users = lib.mkIf config.services.prometheus.exporters.node.enable {
          node-exporter.extraGroups = [ "rapl" ];
        };

        # udev's GROUP/MODE only apply to device nodes, not sysfs attributes.
        services.udev.extraRules = lib.mkIf config.services.prometheus.exporters.node.enable ''
          ACTION=="add", SUBSYSTEM=="powercap", TEST=="energy_uj", RUN+="${pkgs.coreutils}/bin/chgrp rapl /sys%p/energy_uj", RUN+="${pkgs.coreutils}/bin/chmod 0440 /sys%p/energy_uj"
        '';
      };
}
