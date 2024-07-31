# auto disk partitioning:
#   nix run github:nix-community/disko -- --mode disko ./disko-fs.nix
{
  disko.devices = {
    disk.data-apps = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EJRX-89T1XY0_WD-WCC7K0XDCZE6";
      content = {
        type = "gpt";
        partitions.data-apps = {
          size = "100%";
          content = {
            type = "btrfs";
            # extraArgs = ["-f"]; # Override existing partition
            subvolumes = {
              "@persistent" = {
                mountpoint = "/data/apps";
                mountOptions = ["compress-force=zstd:1" "noatime"];
              };
              "@backups" = {
                mountpoint = "/data/backups";
                mountOptions = ["compress-force=zstd:1" "noatime"];
              };
              "@snapshots" = {
                mountpoint = "/data/apps-snapshots";
                mountOptions = ["compress-force=zstd:1" "noatime"];
              };
            };
          };
        };
      };
    };
    disk.data-fileshare = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K7VV9613";
      content = {
        type = "gpt";
        partitions.data-fileshare = {
          size = "100%";
          content = {
            type = "btrfs";
            # extraArgs = ["-f"]; # Override existing partition
            subvolumes = {
              "@persistent" = {
                mountpoint = "/data/fileshare";
                mountOptions = ["compress-force=zstd:1" "noatime"];
              };
              "@snapshots" = {
                mountpoint = "/data/fileshare-snapshots";
                mountOptions = ["compress-force=zstd:1" "noatime"];
              };
            };
          };
        };
      };
    };
  };
}
