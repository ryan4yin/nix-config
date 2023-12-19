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
      "vers=3.0,uid=1000,gid=100,dir_mode=0755,file_mode=0755,mfsymlinks,credentials=${config.age.secrets.smb-credentials.path},nofail"
    ];
  };
}
