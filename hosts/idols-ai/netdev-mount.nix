{
  config,
  ...
}:
{
  # enable davfs2 driver for webdav
  services.davfs2.enable = true;

  # mount a webdav share
  # https://wiki.archlinux.org/title/Davfs2
  fileSystems."/mnt/fileshare" = {
    device = "https://webdav.writefor.fun/";
    fsType = "davfs";
    options = [
      # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
      "nofail"
      "_netdev" # Wait for network
      "rw"
      "uid=1000,gid=100,dir_mode=0750,file_mode=0750"
    ];
  };
  # davfs2 reads its credentials from /etc/davfs2/secrets
  environment.etc."davfs2/secrets" = {
    source = config.age.secrets."davfs-secrets".path;
    mode = "0600";
  };
}
