{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.canokey;
in
{
  options.modules.desktop.canokey = {
    enable = lib.mkEnableOption "CanoKey hardware security key support";
  };

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

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
    ];
  };
}
