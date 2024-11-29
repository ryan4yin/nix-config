{
  config,
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}: {
  imports = [
    agenix.darwinModules.default
  ];

  # enable logs for debugging
  launchd.daemons."activate-agenix".serviceConfig = {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key" # macOS, using the host key for decryption
  ];

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
      owner = myvars.username;
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

    "rclone.conf" =
      {
        file = "${mysecrets}/rclone.conf.age";
      }
      // high_security;

    "nix-access-tokens" =
      {
        file = "${mysecrets}/nix-access-tokens.age";
      }
      # access-token needs to be readable by the user running the `nix` command
      // user_readable;

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
    # Fix DNS for WireGuard on macOS: https://github.com/ryan4yin/nix-config/issues/5
    "wireguard/wg-business.conf" = {
      source = config.age.secrets."wg-business.conf".path;
    };

    "agenix/rclone.conf" = {
      source = config.age.secrets."rclone.conf".path;
    };

    "agenix/ssh-key-romantic" = {
      source = config.age.secrets."ssh-key-romantic".path;
    };

    "agenix/ryan4yin-gpg-subkeys.priv.age" = {
      source = config.age.secrets."ryan4yin-gpg-subkeys.priv.age".path;
    };

    # The following secrets are used by home-manager modules
    # But nix-darwin doesn't support environment.etc.<name>.mode
    # So we need to change its mode manually
    "agenix/alias-for-work.nushell" = {
      source = config.age.secrets."alias-for-work.nushell".path;
    };
    "agenix/alias-for-work.bash" = {
      source = config.age.secrets."alias-for-work.bash".path;
    };
  };

  # both the original file and the symlink should be readable and executable by the user
  #
  # activationScripts are executed every time you run `nixos-rebuild` / `darwin-rebuild` or boot your system
  system.activationScripts.postActivation.text = ''
    ${pkgs.nushell}/bin/nu -c '
      if (ls /etc/agenix/ | length) > 0 {
        sudo chown ${myvars.username} /etc/agenix/*
      }
    '
  '';
}
