{
  fileSystems."/data/downloads" = {
    device = "/dev/disk/by-label/Downloads";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000"];
  };
  fileSystems."/data/games" = {
    device = "/dev/disk/by-label/Games";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000"];
  };
}
