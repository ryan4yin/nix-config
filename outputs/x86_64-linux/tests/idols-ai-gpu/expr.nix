{
  lib,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  niriHardware = builtins.readFile ../../../../hosts/idols-ai/niri-hardware.kdl;
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
}
