{
  config,
  pkgs,
  agenix,
  mysecrets,
  username,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # To decrypt secrets on boot, this key should exists when the system is booting,
    # so we should use the real key file path(prefixed by `/persistent/`) here, instead of the path mounted by impermanence.
    "/persistent/etc/ssh/ssh_host_ed25519_key" # Linux
  ];

  # owner = root
  age.secrets = let
    noaccess = {
      mode = "0000";
      owner = "root";
    };
    high_security = {
      mode = "0500";
      owner = "root";
    };
    user_readable = {
      mode = "0500";
      owner = username;
    };
  in {
    # ---------------------------------------------
    # no one can read/write this file, even root.
    # ---------------------------------------------

    # .age means the decrypted file is still encrypted by age(via a passphrase)
    "ryan4yin-gpg-subkeys.priv.age" =
      {
        file = "${mysecrets}/ryan4yin-gpg-subkeys-2024-01-27.priv.age.age";
      }
      // noaccess;

    # ---------------------------------------------
    # only root can read this file.
    # ---------------------------------------------

    "wg-business.conf" =
      {
        file = "${mysecrets}/wg-business.conf.age";
      }
      // high_security;

    # Used only by NixOS Modules
    # smb-credentials is referenced in /etc/fstab, by ../hosts/ai/cifs-mount.nix
    "smb-credentials" =
      {
        file = "${mysecrets}/smb-credentials.age";
      }
      // high_security;

    "rclone.conf" =
      {
        file = "${mysecrets}/rclone.conf.age";
      }
      // high_security;

    "nix-access-tokens" =
      {
        file = "${mysecrets}/nix-access-tokens.age";
      }
      // high_security;

    # ---------------------------------------------
    # user can read this file.
    # ---------------------------------------------

    "ssh-key-romantic" =
      {
        file = "${mysecrets}/ssh-key-romantic.age";
      }
      // user_readable;

    # alias-for-work
    "alias-for-work.nushell" =
      {
        file = "${mysecrets}/alias-for-work.nushell.age";
      }
      // user_readable;

    "alias-for-work.bash" =
      {
        file = "${mysecrets}/alias-for-work.bash.age";
      }
      // user_readable;
  };

  # place secrets in /etc/
  environment.etc = {
    # wireguard config used with `wg-quick up wg-business`
    "wireguard/wg-business.conf" = {
      source = config.age.secrets."wg-business.conf".path;
    };

    "agenix/rclone.conf" = {
      source = config.age.secrets."rclone.conf".path;
    };

    "agenix/ssh-key-romantic" = {
      source = config.age.secrets."ssh-key-romantic".path;
      mode = "0600";
      user = username;
    };

    "agenix/ryan4yin-gpg-subkeys.priv.age" = {
      source = config.age.secrets."ryan4yin-gpg-subkeys.priv.age".path;
      mode = "0000";
    };

    # The following secrets are used by home-manager modules
    # So we need to make then readable by the user
    "agenix/alias-for-work.nushell" = {
      source = config.age.secrets."alias-for-work.nushell".path;
      mode = "0644"; # both the original file and the symlink should be readable and executable by the user
    };
    "agenix/alias-for-work.bash" = {
      source = config.age.secrets."alias-for-work.bash".path;
      mode = "0644"; # both the original file and the symlink should be readable and executable by the user
    };
  };
}
