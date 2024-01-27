{
  config,
  username,
  ...
}: {
  # mount a smb/cifs share
  fileSystems."/home/${username}/SMB-Downloads" = {
    device = "//192.168.5.194/Downloads";
    fsType = "cifs";
    options = [
      # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
      "nofail,_netdev,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
      "uid=1000,gid=100,dir_mode=0755,file_mode=0755"
      "vers=3.0,credentials=${config.age.secrets.smb-credentials.path}"
    ];
    depends = ["/persistent" "/boot" "/swap/swapfile"];
  };
}
