{ config, lib, ... }:
let
  consumers = map (n: "${n}.service") [
    "immich-server"
    "jellyfin"
    "nginx"
    "restic-backups-homelab"
    "restic-rest-server"
    "restic-server-snapshot"
    "rustfs"
    "sftpgo"
    "transmission"
  ];
in
{
  # The nofail /data mounts can finish after systemd-tmpfiles-setup, so apply
  # the /data rules again once they are mounted.
  systemd.services.data-tmpfiles = {
    description = "Create tmpfiles.d entries on the /data mounts";
    wantedBy = [ "multi-user.target" ] ++ consumers;
    before = consumers;
    unitConfig.WantsMountsFor = lib.filter (lib.hasPrefix "/data/") (lib.attrNames config.fileSystems);
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.systemd.package}/bin/systemd-tmpfiles --create --remove --boot --prefix=/data";
      SuccessExitStatus = "DATAERR CANTCREAT";
    };
  };
}
