# auto disk partitioning:
#   nix run github:nix-community/disko -- --mode disko ./disko-fs.nix
let
  cryptKeyFile = "/etc/agenix/hdd-luks-crypt-key";
  unlockDisk = "data-encrypted";
in
{
  fileSystems."/data/fileshare/public".depends = [ "/data/fileshare" ];

  # By adding this crypttab entry, the disk will be unlocked by systemd-cryptsetup@xxx.service at boot time.
  # This systemd service is running after agenix, so that the keyfile is already available.
  environment.etc = {
    "crypttab".text = ''
      ${unlockDisk} /dev/disk/by-partlabel/disk-${unlockDisk}-luks ${cryptKeyFile} luks,discard,keyfile-size=32768,keyfile-offset=65536
    '';
  };

  disko.devices = {
    disk.data-encrypted = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K7VV9613";
      content = {
        type = "gpt";
        partitions = {
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "data-encrypted";
              settings = {
                keyFile = cryptKeyFile;
                # The maximum size of the keyfile is 8192 KiB
                # type `cryptsetup --help` to see the compiled-in key and passphrase maximum sizes
                # to generate a key file:
                #    dd bs=512 count=1024 iflag=fullblock if=/dev/random of=./hdd-luks-crypt-key
                keyFileSize = 512 * 64; # match the `bs * count` of the `dd` command
                keyFileOffset = 512 * 128; # match the `bs * skip` of the `dd` command
                fallbackToPassword = true;
                allowDiscards = true;
              };
              # Whether to add a boot.initrd.luks.devices entry for the specified disk.
              # The keyfile do not exist before agenix decrypts its data, do we have to disable this option.
              # Otherwise, the initrd will fail to unlock the disk, which causes the boot process to fail.
              initrdUnlock = false;

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
                extraArgs = [ "-f" ]; # Force override existing partition
                subvolumes = {
                  "@apps" = {
                    mountpoint = "/data/apps";
                    mountOptions = [
                      "compress-force=zstd:1"
                      # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
                      "nofail"
                    ];
                  };
                  "@fileshare" = {
                    mountpoint = "/data/fileshare";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                  "@backups" = {
                    mountpoint = "/data/backups";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/data/apps-snapshots";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
    disk.data-public = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EJRX-89T1XY0_WD-WCC7K0XDCZE6";
      content = {
        type = "gpt";
        partitions.data-fileshare = {
          size = "100%";
          content = {
            type = "btrfs";
            # extraArgs = ["-f"]; # Override existing partition
            subvolumes = {
              "@persistent" = {
                mountpoint = "/data/fileshare/public";
                mountOptions = [
                  "compress-force=zstd:1"
                  "nofail"
                ];
              };
            };
          };
        };
      };
    };
  };
}
