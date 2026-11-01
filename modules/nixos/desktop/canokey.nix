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

  config = lib.mkIf cfg.enable {
    # systemd tags FIDO/CCID devices uaccess (60-fido-id.rules); pcscd covers OpenPGP.
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      ccid
      pcsc-tools
    ];
  };
}
