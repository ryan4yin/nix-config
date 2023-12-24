{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop.i3;
in {
  options.modules.desktop.i3 = {
    nvidia = mkEnableOption "whether nvidia GPU is used";
  };

  config = mkIf (cfg.enable && cfg.nvidia) (
    let
      env = {
        "LIBVA_DRIVER_NAME" = "nvidia";
        "GBM_BACKEND" = "nvidia-drm";
        "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
      };
    in {
      # environment set for systemd's user session
      systemd.user.sessionVariables = env;
      # environment set at user login
      home.sessionVariables = env;
    }
  );
}
