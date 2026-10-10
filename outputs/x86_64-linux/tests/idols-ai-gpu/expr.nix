{
  lib,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  niriHardware = builtins.readFile ../../../../hosts/idols-ai/niri-hardware.kdl;
  preserved = cfg.preservation.preserveAt."/persistent".users.ryan.directories;
  privatelyPreserved =
    path:
    lib.any (
      d: d.directory == cfg.users.users.ryan.home + "/" + path && d.how == "bindmount" && d.mode == "0700"
    ) preserved;
in
{
  loadsVirtualDisplay = builtins.elem "vkms" cfg.boot.kernelModules;
  createsVirtualDisplay = lib.hasInfix "options vkms create_default_dev=1" cfg.boot.extraModprobeConfig;
  niriUsesIntelRenderer = lib.hasInfix "/dev/dri/by-path/pci-0000:00:02.0-render" niriHardware;
  sunshineUserHasInputAccess = builtins.elem "input" cfg.users.users.ryan.extraGroups;
  sunshineHasSysAdmin = cfg.services.sunshine.capSysAdmin;
  sunshineUsesWlrCapture = cfg.services.sunshine.settings.capture;
  sunshineStartsAfterNiri = builtins.elem "niri.service" cfg.systemd.user.services.sunshine.after;
  sunshineWaitsForNiriOutput = lib.hasInfix "niri msg outputs" cfg.systemd.user.services.sunshine.preStart;

  wivrnEnabled = cfg.services.wivrn.enable;
  wivrnAutoStarts = builtins.elem "default.target" cfg.systemd.user.services.wivrn.wantedBy;
  wivrnHighPriority = cfg.services.wivrn.highPriority;
  wivrnWaitsForBus =
    cfg.systemd.user.services.wivrn.serviceConfig.Type == "dbus"
    && cfg.systemd.user.services.wivrn.serviceConfig.BusName == "io.github.wivrn.Server"
    && cfg.systemd.user.services.wivrn.serviceConfig.TimeoutStartSec == "30s";
  wivrnImportsOpenXRToSteam =
    cfg.environment.sessionVariables.PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES == "1";
  wivrnUsesNvidiaVulkan = cfg.services.wivrn.monadoEnvironment.__VK_LAYER_NV_optimus == "NVIDIA_only";
  wivrnSharesDgpuEnvWithGamescope =
    cfg.services.wivrn.monadoEnvironment == cfg.programs.gamescope.env;
  wivrnStatePreserved = privatelyPreserved ".config/wivrn";
  adbStatePreserved = privatelyPreserved ".android";
}
