{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop.vinput;
  vinput = inputs.fcitx5-vinput.packages.${pkgs.stdenv.hostPlatform.system}.fcitx5-vinput;
in
{
  options.modules.desktop.vinput.enable = lib.mkEnableOption "Fcitx5 Vinput voice input";

  config = lib.mkIf cfg.enable {
    i18n.inputMethod.fcitx5.addons = [ vinput ];

    xdg.configFile."fcitx5/conf/vinput.conf" = {
      text = ''
        [Trigger]
        MenuKey=Super_R
      '';
      force = true;
    };

    systemd.user.services.vinput-daemon = {
      Unit = {
        Description = "Fcitx5 Vinput voice input daemon";
        After = [ "pipewire.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.fcitx.Vinput";
        ExecStart = "${vinput}/bin/vinput-daemon";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
