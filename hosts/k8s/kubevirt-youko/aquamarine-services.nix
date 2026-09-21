{
  mylib,
  ...
}:
{
  # aquamarine's services now run directly on this host, migrated off the
  # KubeVirt VM. Its HDD disko config only defines the two data disks (no root
  # disk), so it can be imported here as-is -- disko's NixOS module only
  # generates the fileSystems/mounts, it never reformats.
  imports = map mylib.relativeToRoot [
    "hosts/idols-aquamarine/caddy.nix"
    "hosts/idols-aquamarine/disko-fs.nix"
    "hosts/idols-aquamarine/exporters"
    "hosts/idols-aquamarine/gitea.nix"
    "hosts/idols-aquamarine/grafana"
    "hosts/idols-aquamarine/monitoring"
    "hosts/idols-aquamarine/oci-containers"
    "hosts/idols-aquamarine/postgresql.nix"
    "hosts/idols-aquamarine/proxy.nix"
    "hosts/idols-aquamarine/restic.nix"
    "hosts/idols-aquamarine/sftpgo.nix"
    "hosts/idols-aquamarine/transmission.nix"
  ];

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
