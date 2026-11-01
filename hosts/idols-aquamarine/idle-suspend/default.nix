{
  mylib,
  myvars,
  pkgs,
  ...
}:
let
  idleMinutes = 60;
in
{
  # BIOS: `Wake By Lan` must be enabled; EUP must not cut the NIC's standby
  # power. The `.link` unit did not survive this driver's initialisation, so
  # apply the setting explicitly after udev has created the interface.
  systemd.services.wake-on-lan = {
    description = "Enable Wake-on-LAN on the wired NIC";
    wantedBy = [ "multi-user.target" ];
    after = [
      "systemd-udevd.service"
      "network-pre.target"
    ];
    before = [ "network.target" ];
    path = [
      pkgs.coreutils
      pkgs.ethtool
    ];
    serviceConfig = mylib.systemdHardening.privilegedOneshot // {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = false;
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_NETLINK"
        "AF_UNIX"
      ];
    };
    script = ''
      for _ in $(seq 1 60); do
        found=
        for iface in /sys/class/net/en*; do
          [ -e "$iface" ] || continue
          if ethtool -s "$(basename "$iface")" wol g; then
            found=1
          fi
        done
        [ -n "$found" ] && exit 0
        sleep 1
      done
      echo "no wired interface accepted Wake-on-LAN" >&2
      exit 1
    '';
  };

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

  powerManagement.resumeCommands = ''
    ${pkgs.coreutils}/bin/date +%s > /run/aquamarine-idle-suspend
    for iface in /sys/class/net/en*; do
      [ -e "$iface" ] || continue
      ${pkgs.ethtool}/bin/ethtool -s "$(basename "$iface")" wol g || true
    done
  '';
}
