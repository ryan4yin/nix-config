{
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  hm = cfg.home-manager.users.ryan;
  packageNames = map (package: package.pname or "") hm.i18n.inputMethod.fcitx5.addons;
in
{
  enablesLocalAsr = builtins.elem "fcitx5-vinput" packageNames;
  enablesLitePackage = builtins.elem "fcitx5-vinput-lite" packageNames;
  hasVinputDaemon = hm.systemd.user.services ? vinput-daemon;
}
