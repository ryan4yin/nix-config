{
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}:
{
  imports = [
    agenix.darwinModules.default
  ];

  # enable logs for debugging
  launchd.daemons."activate-agenix".serviceConfig = {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };

  environment.systemPackages = [
    agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key" # macOS, using the host key for decryption
  ];

  age.secrets =
    let
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
    in
    {
      # ---------------------------------------------
      # No discretionary access; privileged root can still bypass file modes.
      # ---------------------------------------------

      # .age means the decrypted file is still encrypted by age(via a passphrase)
      "ryan4yin-gpg-subkeys.priv.age" = {
        file = "${mysecrets}/desktop/ryan4yin-gpg-subkeys-2024-01-27.priv.age.age";
        path = "/etc/agenix/ryan4yin-gpg-subkeys.priv.age";
      }
      // noaccess;

      # ---------------------------------------------
      # only root can read this file.
      # ---------------------------------------------

      "rclone.conf" = {
        file = "${mysecrets}/desktop/rclone.conf.age";
        path = "/etc/agenix/rclone.conf";
      }
      // high_security;

      "nix-access-tokens" = {
        file = "${mysecrets}/server/nix-access-tokens.age";
      }
      # access-token needs to be readable by the user running the `nix` command
      // user_readable;

      # ---------------------------------------------
      # user can read this file.
      # ---------------------------------------------

      "ssh-key-romantic" = {
        file = "${mysecrets}/desktop/ssh-key-romantic.age";
        path = "/etc/agenix/ssh-key-romantic";
      }
      // user_readable;

      # work git identity, symlinked to ~/work/.gitconfig by home-manager
      "work-gitconfig" = {
        file = "${mysecrets}/desktop/work-gitconfig.age";
        path = "/etc/agenix/work-gitconfig";
      }
      // user_readable;
    };

}
