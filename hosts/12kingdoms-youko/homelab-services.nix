{ ... }:
{
  # The homelab service modules (caddy, gitea, grafana, monitoring, oci
  # containers, postgresql, restic, sftpgo, transmission, and the HDD disko
  # config) live in ./homelab-services/ and are auto-imported by this host's
  # scanPaths. Its HDD disko config only defines the two data disks (no root
  # disk), so it is imported as-is -- disko's NixOS module only generates the
  # fileSystems/mounts, it never reformats.

  # the same secret groups the aqua VM enabled
  modules.secrets.server = {
    application.enable = true;
    operation.enable = true;
    webserver.enable = true;
    storage.enable = true;
  };
}
