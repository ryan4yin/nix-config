{ outputs, ... }:
let
  systemd = outputs.nixosConfigurations.youko.config.systemd.package;
in
{
  wantsMountsFor = [
    "/data/apps"
    "/data/apps-snapshots"
    "/data/backups"
    "/data/fileshare"
    "/data/fileshare/public"
  ];
  execStart = "${systemd}/bin/systemd-tmpfiles --create --remove --boot --prefix=/data";
  setupWaitsForData = false;
}
