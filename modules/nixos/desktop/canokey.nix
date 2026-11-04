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

  # Usage policy: Linux PCs only *use* the CanoKey (WebAuthn/passkeys, OpenPGP,
  # SSH). All CanoKey Console management (Admin PIN, per-application and
  # factory reset, NDEF/LED/WebUSB settings) happens only in the phone app, and
  # the Admin PIN is never typed on a PC. A compromised PC then cannot learn the
  # Admin PIN and so cannot reset applications or change device settings with it.
  #
  # What the config enforces: sandboxed browsers see only the FIDO HID
  # interface (hardening/nixpaks), never raw USB or CCID, so the WebUSB console
  # is unreachable from them; the vendor's WebUSB udev rule (MODE 0666 on the
  # raw USB node) is deliberately not installed.
  # What it does not enforce: systemd still grants the session user the raw USB
  # node (CCID reader -> uaccess), and the Admin applet is also reachable over
  # PC/SC, so unsandboxed software could talk to it. Browsers can also use
  # standard CTAP to set/change the FIDO2 PIN, manage passkeys and reset the
  # FIDO application (reset needs a touch). Keeping management on the phone is
  # a usage rule, not a technical barrier.
  config = lib.mkIf cfg.enable {
    # systemd tags FIDO/CCID devices uaccess (60-fido-id.rules); pcscd covers OpenPGP.
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
    ];
  };
}
