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

  config = lib.mkIf cfg.enable {
    services.pcscd.enable = true;

    # The FIDO2 udev rule below hands the key to the plugdev group.
    users.users.${myvars.username}.extraGroups = [ "plugdev" ];

    services.udev.extraRules = ''
      # CanoKey - GnuPG/pcsclite
      SUBSYSTEM!="usb", GOTO="canokey_rules_end"
      ACTION!="add|change", GOTO="canokey_rules_end"
      ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42d4", ENV{ID_SMARTCARD_READER}="1"
      LABEL="canokey_rules_end"

      # CanoKey - FIDO2
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42d4", TAG+="uaccess", GROUP="plugdev", MODE="0660"

      # CanoKey - WebUSB
      # Upstream ships this as MODE:="0666" (world-writable), which lets any
      # local user access the key; restrict it to the plugdev group instead.
      SUBSYSTEMS=="usb", ATTR{idVendor}=="20a0", ATTR{idProduct}=="42d4", GROUP="plugdev", MODE="0660"
    '';

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
    ];
  };
}
