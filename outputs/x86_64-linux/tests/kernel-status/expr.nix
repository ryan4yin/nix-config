{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    config = outputs.nixosConfigurations.${name}.config;
    exporter = config.services.prometheus.exporters.node;
    reporter = config.systemd.services.nixos-kernel-status.serviceConfig or { };
    timer = config.systemd.timers.nixos-kernel-status or { };
  in
  {
    collector = builtins.elem "textfile" exporter.enabledCollectors;
    directory = builtins.elem "--collector.textfile.directory=/run/nixos-kernel-status" exporter.extraFlags;
    unprivileged =
      !exporter.enable
      || (
        (reporter.User or "root") == exporter.user
        && exporter.user != "root"
        && !(reporter.DynamicUser or false)
      );
    noNewPrivileges = !exporter.enable || (reporter.NoNewPrivileges or false);
    timerMatchesExporter = (builtins.elem "timers.target" (timer.wantedBy or [ ])) == exporter.enable;
    boundedInterval = !exporter.enable || (timer.timerConfig.OnUnitActiveSec or null) == "5m";
  }
)
