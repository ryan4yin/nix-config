# Private XDG directories under ~/.var/app/<appId>, mounted over the host's.
# Game launchers turn this off and mount a whole private home instead (see
# gaming-policy.nix): games also write outside XDG, straight into $HOME.
{
  config,
  lib,
  sloth,
  ...
}:
{
  options.xdgStorage.enable =
    lib.mkEnableOption "private per-app XDG cache, config, data and state directories"
    // {
      default = true;
    };
  config.bubblewrap.bind.rw = lib.mkIf config.xdgStorage.enable (
    with sloth;
    [
      [
        (mkdir appCacheDir)
        xdgCacheHome
      ]
      [
        (mkdir appConfigDir)
        xdgConfigHome
      ]
      [
        (mkdir appDataDir)
        xdgDataHome
      ]
      [
        (mkdir (concat' appDir "/state"))
        xdgStateHome
      ]
    ]
  );
}
