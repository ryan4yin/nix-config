{
  disko.devices = {
    # TODO: rename to nvme0n1
    disk.sda = {
      type = "disk";
      # When using disko-install, we will overwrite this value from the commandline
      device = "/dev/nvme0n1"; # The device to partition
      content = {
        type = "gpt";
        partitions = {
          # The EFI & Boot partition
          ESP = {
            size = "630M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };
          # The root partition
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings = {
                keyFile = "/dev/disk/by-label/OPI5_DSC"; # The keyfile is stored on a USB stick
                # The maxium size of the keyfile is 8192 bytes
                keyFileSize = 512 * 64; # match the `bs * count` of the `dd` command
                keyFileOffset = 512 * 128; # match the `bs * skip` of the `dd` command
                fallbackToPassword = true;
                allowDiscards = true;
              };
              # Whether to add a boot.initrd.luks.devices entry for the specified disk.
              initrdUnlock = true;

              # encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
              # cryptsetup luksFormat
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                # use true random data from /dev/random, will block until enough entropy is available
                "--use-random"
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  # TODO: tmpfs on root
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress-force=zstd:1"];
                  };
                  "@lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = ["compress-force=zstd:1"];
                  };

                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "8192M";
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
