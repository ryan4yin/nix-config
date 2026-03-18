# Disko layout for idols-ai data disk (LUKS + btrfs, mount at /persistent/data).
#
# Destroy, format & mount (wipes disk; from nixos-installer: cd nix-config/nixos-installer):
#   nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs-data.nix
# Mount only (after first format):
#   nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs-data.nix
#
{
  disko.devices = {
    disk.data = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582";
      content = {
        type = "gpt";
        partitions = {
          datapart = {
            size = "100%";
            content = {
              type = "luks";
              name = "data-luks"; # Mapper name; match boot.initrd.luks
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
                  "@data" = {
                    mountpoint = "/data";
                    mountOptions = [
                      "compress-force=zstd:1"
                    ];
                  };
                };
                postMountHook = ''
                  chown ryan:users /mnt/data
                  # Set SGID + rwx for owner/group, read-only for others; new files inherit group
                  chmod 2755 /mnt/data
                '';
              };
            };
          };
        };
      };
    };
  };
}
