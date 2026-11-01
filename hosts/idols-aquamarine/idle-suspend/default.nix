{
  myvars,
  pkgs,
  ...
}:
let
  idleMinutes = 60;
in
{
  # Suspend only after a long idle period. WoL is an interlock: if the NIC is
  # not armed, suspending would make the host unreachable from the LAN.
  systemd.services.aquamarine-idle-suspend = {
    description = "Suspend aquamarine after a long idle period";
    path = [
      pkgs.ethtool
      pkgs.iproute2
      pkgs.systemd
    ];
    environment = {
      AQUAMARINE_ASR_PORT = toString myvars.ports.aquamarineAsr;
      AQUAMARINE_IDLE_MINUTES = toString idleMinutes;
    };
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "5min";
      PrivateTmp = true;
      ExecStart = "${pkgs.python3}/bin/python3 ${./idle-suspend.py}";
    };
  };

  systemd.timers.aquamarine-idle-suspend = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1min";
    };
  };

  # A wake should not immediately go back to sleep.
  powerManagement.resumeCommands = ''
    ${pkgs.coreutils}/bin/date +%s > /run/aquamarine-idle-suspend
  '';
}
