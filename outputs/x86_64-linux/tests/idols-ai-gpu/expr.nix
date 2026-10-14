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
  # Compare package names: `builtins.elem "intel-media-driver"` compares a string
  # against derivations and passes even when the driver is installed.
  graphicsPackageNames = map (package: package.pname or "") (
    cfg.hardware.graphics.extraPackages or [ ]
  );
in
{
  loadsVirtualDisplay = builtins.elem "vkms" cfg.boot.kernelModules;
  createsVirtualDisplay = lib.hasInfix "options vkms create_default_dev=1" cfg.boot.extraModprobeConfig;
  # The RTX 4090 is the only GPU here, so niri must not be pinned to a render node.
  niriPinsNoRenderDevice = !lib.hasInfix "render-drm-device" niriHardware;
  noIntelGraphicsStack =
    !(builtins.any (
      name:
      builtins.elem name [
        "intel-media-driver"
        "vpl-gpu-rt"
        "intel-compute-runtime"
      ]
    ) graphicsPackageNames);
  # The same change dropped the VA-API override, which only an Intel GPU could serve.
  noIntelLibvaOverride = !(cfg.environment.sessionVariables ? LIBVA_DRIVER_NAME);
  noPrimeOffload = !cfg.hardware.nvidia.prime.offload.enable;
  sunshineUserHasInputAccess = builtins.elem "input" cfg.users.users.ryan.extraGroups;
  sunshineHasSysAdmin = cfg.services.sunshine.capSysAdmin;
  sunshineUsesWlrCapture = cfg.services.sunshine.settings.capture;
  sunshineStartsAfterNiri = builtins.elem "niri.service" cfg.systemd.user.services.sunshine.after;
  sunshineWaitsForNiriOutput = lib.hasInfix "niri msg outputs" cfg.systemd.user.services.sunshine.preStart;
  # Sunshine encodes with NVENC on the 4090, so no VA-API adapter is pinned.
  sunshinePinsNoAdapter = cfg.services.sunshine.settings.adapter_name or null == null;

  wivrnEnabled = cfg.services.wivrn.enable;
  wivrnAutoStarts = builtins.elem "default.target" cfg.systemd.user.services.wivrn.wantedBy;
  wivrnHighPriority = cfg.services.wivrn.highPriority;
  wivrnWaitsForBus =
    cfg.systemd.user.services.wivrn.serviceConfig.Type == "dbus"
    && cfg.systemd.user.services.wivrn.serviceConfig.BusName == "io.github.wivrn.Server"
    && cfg.systemd.user.services.wivrn.serviceConfig.TimeoutStartSec == "30s";
  wivrnImportsOpenXRToSteam =
    cfg.environment.sessionVariables.PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES == "1";
  wivrnStatePreserved = privatelyPreserved ".config/wivrn";
  adbStatePreserved = privatelyPreserved ".android";
}
