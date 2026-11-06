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

    # A blink is easy to miss, so touch requests also raise a desktop
    # notification. The package's service starts with graphical-session.target
    # and sends through libnotify by default; Noctalia plays a sound for this
    # sender only (home/linux/gui/base/noctalia/config/config.toml). Coverage
    # and limits: docs/security-keys.md.
    programs.yubikey-touch-detector.enable = true;
    systemd.user.services.yubikey-touch-detector.environment = {
      YUBIKEY_TOUCH_DETECTOR_NOTIFY_TITLE = "Security key: touch needed";
      YUBIKEY_TOUCH_DETECTOR_NOTIFY_BODY = "Touch the security key to continue";
    };

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
      pam_u2f # pamu2fcfg
    ];
  };
}
