{
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  hm = cfg.home-manager.users.ryan;
  packageNames = map (package: package.pname or "") hm.i18n.inputMethod.fcitx5.addons;
  vinputPackage = builtins.head (
    builtins.filter (
      package: (package.pname or "") == "fcitx5-vinput"
    ) hm.i18n.inputMethod.fcitx5.addons
  );
  daemonEnvironment = hm.systemd.user.services.vinput-daemon.Service.Environment;
in
{
  enablesLocalAsr = builtins.elem "fcitx5-vinput" packageNames;
  enablesLitePackage = builtins.elem "fcitx5-vinput-lite" packageNames;
  sherpaOnnxVersion = vinputPackage.passthru.sherpaOnnxVersion or "";
  hasVinputDaemon = hm.systemd.user.services ? vinput-daemon;
  hasOpenvinoServer = hm.systemd.user.services ? openvino-npu-stt;
  exposesNpuRuntimeLibraries = builtins.any (
    variable: builtins.match "LD_LIBRARY_PATH=.*:/run/opengl-driver/lib" variable != null
  ) daemonEnvironment;
  enablesIntelNpu = cfg.hardware.cpu.intel.npu.enable;
}
