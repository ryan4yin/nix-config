# WeChat data and its sandbox boundary are owned by nixpak.
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}:
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  pasta.mode = "isolate";
  desktopIntegration.tray = true;
  portalGroups = {
    fileChooser = true;
    openUri = true;
    notifications = true;
    screenCast = true;
    camera = true;
    inputMethod = true;
  };
  bubblewrap = {
    sockets.x11 = true;
    # libdbus aborts without /etc/machine-id; use a synthetic app-scoped value.
    bind.ro = [
      [
        (toString (
          pkgs.writeText "wechat-machine-id" "${
            builtins.substring 0 32 (builtins.hashString "sha256" config.flatpak.appId)
          }\n"
        ))
        "/etc/machine-id"
      ]
    ];
    bind.rw = [
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
    ];
    env = {
      # WeChat keeps .xwechat and xwechat_files under HOME. User-selected
      # files also go through the XDG file chooser portal where available.
      HOME = lib.mkForce (sloth.concat' sloth.xdgDataHome "/wechat");
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
      XDG_DOCUMENTS_DIR = sloth.xdgDocumentsDir;
      XDG_DOWNLOAD_DIR = sloth.xdgDownloadDir;
      PATH = lib.makeBinPath [ pkgs.coreutils ];
    };
  };
}
