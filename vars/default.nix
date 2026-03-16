{ lib }:
{
  username = "ryan";
  userfullname = "Ryan Yin";
  useremail = "xiaoyin_c@qq.com";
  networking = import ./networking.nix { inherit lib; };
  # Generated using: mkpasswd -m yescrypt --rounds=11
  # Password: long, strong random string (full charset)
  # Rotation policy: changed annually
  # Purpose: system login password only
  # https://man.archlinux.org/man/crypt.5.en
  initialHashedPassword = "$y$jFT$RBapCH3F6bc0uSF.FaUGB.$rvhiVvcCKxkkumDFLONV5zFP1lsv1VyZ1ErH.r2rNk3";
  # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
  #
  # Since its authority is so large, we must strengthen its security:
  # 1. The corresponding private key must be:
  #    1. Generated locally on every trusted client via:
  #      ```bash
  #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
  #      # Passphrase: digits + letters + symbols, 12+ chars
  #      ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx
  #      ```
  #    2. Never leave the device and never sent over the network.
  # 2. Or just use hardware security keys like Yubikey/CanoKey.
  mainSshAuthorizedKeys = [
    # The main ssh keys for daily usage
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKlN+Q/GxvwxDX/OAjJHaNFEznEN4Tw4E4TwqQu/eD6 ryan@idols-ai"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwoI5MAogEa726jwwHL5EgM1X/i2A5d2pgV7i7t8fzB ryan@shoukei"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDc1PNTXzzvd93E+e9LXvnEzqgUI5gMTEF/IitvzgmL+ ryan@frieren"
  ];
  secondaryAuthorizedKeys = [
    # the backup ssh keys for disaster recovery
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzYT0Fpcp681eHY5FJV2G8Mve53iX3hMOLGbVvfL+TF ryan@romantic"
  ];
}
