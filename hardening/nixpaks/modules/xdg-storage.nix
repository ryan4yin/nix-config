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
  config.bubblewrap.bind = lib.mkIf config.xdgStorage.enable (
    with sloth;
    {
      rw = [
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
      ];
      # The host's GTK and KDE theme settings, over the private config
      # directory (nixpak mounts read-only binds after read-write ones).
      ro = [
        (concat' xdgConfigHome "/gtk-2.0")
        (concat' xdgConfigHome "/gtk-3.0")
        (concat' xdgConfigHome "/gtk-4.0")
        (concat' xdgConfigHome "/kdeglobals")
      ];
    }
  );
}
