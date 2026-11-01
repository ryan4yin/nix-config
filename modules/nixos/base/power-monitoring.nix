{
  config,
  lib,
  mylib,
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

        systemd.services.rapl-permissions = lib.mkIf config.services.prometheus.exporters.node.enable {
          description = "Allow node_exporter to read RAPL energy counters";
          wantedBy = [ "multi-user.target" ];
          unitConfig.ConditionPathExists = "/sys/class/powercap";
          serviceConfig = mylib.systemdHardening.privilegedOneshot // {
            Type = "oneshot";
            RemainAfterExit = true;
            CapabilityBoundingSet = [ "CAP_CHOWN" ];
          };
          script = ''
            shopt -s nullglob
            for f in /sys/class/powercap/*/energy_uj; do
              chgrp rapl "$f"
              chmod 0440 "$f"
            done
          '';
        };

        systemd.services.prometheus-node-exporter =
          lib.mkIf config.services.prometheus.exporters.node.enable
            {
              requires = [ "rapl-permissions.service" ];
              after = [ "rapl-permissions.service" ];
            };
      };
}
