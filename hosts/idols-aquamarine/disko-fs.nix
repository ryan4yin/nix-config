# Disko layout for idols-aquamarine's root disk: the Fanxiang S790 2TB that was
# `ai`'s /data disk. Same shape as hosts/idols-ai/disko-fs.nix
# (ESP + LUKS + btrfs subvolumes, ephemeral tmpfs root, preservation on
# /persistent), so the two hosts share one layout and one restore procedure.
#
# The LUKS mapper is named `aqua-luks`, not `nixos-luks`: `ai` already owns that
# name while this disk is formatted (./README.md). disko generates the matching
# boot.initrd.luks entry.
#
# Destroy, format & mount as root (wipes the disk; run from ~/nix-config, and
# check `lsblk` + the by-id path first — see hosts/idols-aquamarine/README.md):
#   sudo nix run github:nix-community/disko -- --mode destroy,format,mount hosts/idols-aquamarine/disko-fs.nix
# Mount only (after the first format):
#   sudo nix run github:nix-community/disko -- --mode mount hosts/idols-aquamarine/disko-fs.nix
{
  # Ephemeral root; preservation mounts /persistent for state.
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    # Ephemeral root; relatime and mode=755 so systemd does not set 777.
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "nosuid" # Ignore setuid bit; no suid binaries live on the root tmpfs
        "nodev" # Ignore device files; nothing here needs to be a device node
        "size=4G"
        "relatime" # Update inode access times relative to modify/change time
        "mode=755"
      ];
    };

    disk.nixos-aquamarine = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582";
      content = {
        type = "gpt";
        partitions = {
          # EFI system partition; must stay unencrypted for UEFI to load the bootloader.
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "600M";
            type = "EF00"; # EF00 = ESP in GPT
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0177" # File mask: 777-177=600 (owner rw-, group/others ---)
                "dmask=0077" # Directory mask: 777-077=700 (owner rwx, group/others ---)
                "noexec,nosuid,nodev" # Security: no execution, ignore setuid, no device nodes
              ];
            };
          };
          # Root partition: LUKS encrypted, then btrfs with subvolumes.
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "aqua-luks"; # Mapper name; match boot.initrd.luks
              settings = {
                allowDiscards = true; # TRIM for SSDs; slightly less secure, better performance
              };
              # Add boot.initrd.luks.devices so initrd prompts for passphrase at boot
              initrdUnlock = true;
              # cryptsetup luksFormat options
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                "--use-random" # Block until enough entropy from /dev/random
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Force overwrite if filesystem already exists
                subvolumes = {
                  # Top-level subvolume (id 5); used for btrfs send/receive and snapshots
                  "/" = {
                    mountpoint = "/btr_pool";
                    mountOptions = [ "subvolid=5" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1" # Save space and reduce I/O on SSD
                      "noatime"
                    ];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "compress-force=zstd:1"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = [
                      "nosuid"
                      "nodev"
                      "compress-force=zstd:1"
                    ];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "nosuid"
                      "nodev"
                      "noatime" # Temp files don't need access times; saves btrfs metadata writes
                      "compress-force=zstd:1"
                    ];
                  };
                  # disko creates the 32G swapfile on this subvolume and adds swapDevices.
                  # It is preallocated and never compressed (btrfs swapfile requirements),
                  # so it consumes its full size on the pool.
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32G";
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
