{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda"; # the virtual disk
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "450M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0177" # File mask: 777-177=600 (Owner: rw-, Group/Others: ---)
                  "dmask=0077" # Directory mask: 777-077=700 (Owner: rwx, Group/Others: ---)
                  "noexec,nosuid,nodev" # Security: Block execution, ignore setuid, and disable device nodes
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountOptions = [ "compress=zstd:1" ];
                    mountpoint = "/home";
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4096M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
