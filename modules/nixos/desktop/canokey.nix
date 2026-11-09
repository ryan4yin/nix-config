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

    # sudo, polkit and other PAM services accept a key touch instead of the
    # password; without the key they ask for the password as before. Nothing
    # changes until myvars.canokeyU2fKeys has an entry (registration:
    # docs/security-keys.md). The global switch, unlike per-service ones, also
    # lets polkit's sandboxed agent helper reach /dev/hidraw*.
    security.pam.u2f.enable = myvars.canokeyU2fKeys != [ ];
    security.pam.u2f.settings = {
      authfile = pkgs.writeText "u2f-keys" ''
        ${myvars.username}:${lib.concatMapStringsSep ":" (lib.removePrefix ":") myvars.canokeyU2fKeys}
      '';
      # Shared by all hosts, so one registration works on idols-ai and shoukei.
      origin = "pam://ryan4yin";
      cue = true;
    };
    # Services that keep the password only. Some have no PAM file or program
    # on these hosts yet; listing them stops a later enable from opening on a
    # bare touch.
    security.pam.services =
      lib.genAttrs
        (
          # The password unlocks the keyring through pam_oo7. greetd and
          # Noctalia's lock screen authenticate through `login`.
          [
            "login"
            "greetd"
          ]
          # Screen lockers: the key usually stays plugged in, so a touch alone
          # would unlock for whoever sits at the desk.
          ++ [
            "swaylock"
            "i3lock"
            "i3lock-color"
            "xlock"
            "xscreensaver"
            "vlock"
          ]
          # Account changes confirm the current password; passwd also hands it
          # to pam_oo7 to re-key the keyring.
          ++ [
            "passwd"
            "chsh"
            "chfn"
          ]
          # su authenticates root, which has no registered key.
          ++ [ "su" ]
          # Unused while ssh.nix disables keyboard-interactive auth. If enabled,
          # a remote login would blink the key at this desk, and a touch meant
          # for sudo would let the remote user in.
          ++ [ "sshd" ]
        )
        (_: {
          u2f.enable = false;
        });

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
