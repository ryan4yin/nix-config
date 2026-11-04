{
  pkgs,
  config,
  lib,
  myvars,
  ...
}:
let
  cfg = config.modules.desktop.canokey;
in
{
  options.modules.desktop.canokey = {
    enable = lib.mkEnableOption "CanoKey hardware security key support";
  };

  # Usage policy, setup, backup keys and recovery: docs/security-keys.md.
  # PCs only use the key and the phone app manages it, so the vendor's WebUSB
  # udev rule (MODE 0666 on the raw USB node) is deliberately not installed.
  config = lib.mkIf cfg.enable {
    # systemd tags FIDO/CCID devices uaccess (60-fido-id.rules); pcscd covers OpenPGP.
    services.pcscd.enable = true;

    # sudo accepts a key touch instead of the password; without the key it asks
    # for the password as before. Login keeps the password, which also unlocks
    # GNOME Keyring. sudo is unchanged until myvars.canokeyU2fKeys has an entry
    # (registration: docs/security-keys.md).
    security.pam.u2f.settings = {
      authfile = pkgs.writeText "u2f-keys" ''
        ${myvars.username}:${lib.concatMapStringsSep ":" (lib.removePrefix ":") myvars.canokeyU2fKeys}
      '';
      # Shared by all hosts, so one registration works on idols-ai and shoukei.
      origin = "pam://ryan4yin";
      cue = true;
    };
    security.pam.services.sudo.u2f.enable = myvars.canokeyU2fKeys != [ ];

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
      pam_u2f # pamu2fcfg
    ];
  };
}
