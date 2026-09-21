{ ... }:
{
  # aquamarine's service modules (caddy, gitea, grafana, monitoring, oci
  # containers, postgresql, restic, sftpgo, transmission, and the HDD disko
  # config) live in ./aquamarine/ and are auto-imported by this host's
  # scanPaths. Its HDD disko config only defines the two data disks (no root
  # disk), so it is imported as-is -- disko's NixOS module only generates the
  # fileSystems/mounts, it never reformats.
  #
  # keep aquamarine's IP on this host's bridge so its services and DNS keep
  # resolving after the migration (the NixOS list option merges with the .183)
  systemd.network.networks."10-br0".networkConfig.Address = [ "192.168.5.101/24" ];

  # the same secret groups the aqua VM enabled
  modules.secrets.server = {
    application.enable = true;
    operation.enable = true;
    webserver.enable = true;
    storage.enable = true;
  };
}
