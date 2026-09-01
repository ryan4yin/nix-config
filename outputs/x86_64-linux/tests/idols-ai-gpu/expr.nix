{
  lib,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  homeSessionVariables = cfg.home-manager.users.ryan.home.sessionVariables;
  niriHardware = builtins.readFile ../../../../hosts/idols-ai/niri-hardware.kdl;
  nvidiaSessionVariables = [
    "GBM_BACKEND"
    "LIBVA_DRIVER_NAME"
    "NVD_BACKEND"
    "__GLX_VENDOR_LIBRARY_NAME"
  ];
in
{
  dynamicBoost = cfg.hardware.nvidia.dynamicBoost.enable;
  loadsVirtualDisplay = builtins.elem "vkms" cfg.boot.kernelModules;
  createsVirtualDisplay = lib.hasInfix "options vkms create_default_dev=1" cfg.boot.extraModprobeConfig;
  niriUsesIntelRenderer = lib.hasInfix "/dev/dri/by-path/pci-0000:00:02.0-render" niriHardware;
  sunshine = {
    adapter_name = cfg.services.sunshine.settings.adapter_name or null;
    encoder = cfg.services.sunshine.settings.encoder or null;
    libvaDriver = cfg.systemd.user.services.sunshine.environment.LIBVA_DRIVER_NAME or null;
    startsAfterNiri = builtins.elem "niri.service" cfg.systemd.user.services.sunshine.after;
    waitsForNiriOutput = lib.hasInfix "niri msg outputs" cfg.systemd.user.services.sunshine.preStart;
  };
  forcedNvidiaSessionVariables = lib.genAttrs nvidiaSessionVariables (
    name: homeSessionVariables.${name} or null
  );
}
