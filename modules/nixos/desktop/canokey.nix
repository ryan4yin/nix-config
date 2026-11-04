{
  pkgs,
  config,
  lib,
  myvars,
  ...
}:
let
  cfg = config.modules.desktop.canokey;
  # Shared by all hosts, so one registration works on idols-ai and shoukei.
  u2fOrigin = "pam://ryan4yin";
in
{
  options.modules.desktop.canokey = {
    enable = lib.mkEnableOption "CanoKey hardware security key support";
  };

  # Setup, backup keys and recovery: docs/security-keys.md
  # CanoKey docs: https://docs.canokeys.org/userguide/
  #
  # Principle: management and use happen on different devices. Linux PCs only
  # use the key (WebAuthn/passkeys, OpenPGP, SSH). CanoKey Console management
  # (Admin PIN, application/factory reset, device settings) happens only in the
  # phone app (https://docs.canokeys.org/userguide/admin/), so the Admin PIN is
  # never typed on a PC.
  #
  # Sandboxed browsers back this up: they see only the FIDO HID interface
  # (hardening/nixpaks), not raw USB or CCID, so the WebUSB console cannot reach
  # the key, and the vendor's WebUSB udev rule (MODE 0666 on the raw USB node)
  # is deliberately not installed. Unsandboxed software is trusted; if it is
  # malicious, the PC is compromised regardless.
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
      origin = u2fOrigin;
      appid = u2fOrigin;
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
