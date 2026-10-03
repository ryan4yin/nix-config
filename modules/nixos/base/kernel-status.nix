{
  config,
  lib,
  pkgs,
  ...
}:
let
  directory = "/run/nixos-kernel-status";
  script = pkgs.writeText "kernel-status.py" (builtins.readFile ../../../scripts/kernel-status.py);
in
{
  # Keep collector configuration outside the enable condition: exporters is
  # an applied attrset, so conditioning its own fields on node.enable recurses.
  services.prometheus.exporters.node = {
    enabledCollectors = [ "textfile" ];
    extraFlags = [ "--collector.textfile.directory=${directory}" ];
  };
  systemd.services.nixos-kernel-status = lib.mkIf config.services.prometheus.exporters.node.enable {
    description = "Report whether the deployed NixOS kernel needs a reboot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 ${script} --output ${directory}/kernel-status.prom";
      # Share the existing non-root exporter account. DynamicUser also places
      # runtime directories under root-only /run/private on current systemd.
      User = config.services.prometheus.exporters.node.user;
      Group = config.services.prometheus.exporters.node.group;
      DynamicUser = false;
      RuntimeDirectory = "nixos-kernel-status";
      RuntimeDirectoryMode = "0755";
      RuntimeDirectoryPreserve = "yes";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      TimeoutStartSec = "30s";
    };
  };
  systemd.timers.nixos-kernel-status = lib.mkIf config.services.prometheus.exporters.node.enable {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      RandomizedDelaySec = "30s";
    };
  };
}
