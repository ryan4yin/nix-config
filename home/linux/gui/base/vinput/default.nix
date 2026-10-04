{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-patched,
  ...
}:
let
  cfg = config.modules.desktop.vinput;
  vinput = import ./package.nix {
    inherit inputs pkgs pkgs-patched;
    backend = cfg.backend;
  };
in
{
  options.modules.desktop.vinput = {
    enable = lib.mkEnableOption "Fcitx5 Vinput voice input";
    backend = lib.mkOption {
      type = lib.types.enum [
        "cpu"
        "openvino"
      ];
      default = "cpu";
      description = "ASR backend used by Vinput: CPU or OpenVINO.";
    };
  };

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
        Environment = lib.optionals (cfg.backend == "openvino") [
          # OpenVINO dlopens Level Zero and discovers the NPU UMD through these paths.
          "LD_LIBRARY_PATH=${pkgs.level-zero}/lib:/run/opengl-driver/lib"
        ];
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
