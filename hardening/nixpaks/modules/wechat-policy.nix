# The existing FHS layer owns WeChat's HOME remapping and xwechat_files link.
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
    # The inner FHS /home reset replaces base XDG mounts with this backing tree.
    bind.rw = lib.mkForce [
      (sloth.mkdir (sloth.concat' sloth.xdgDocumentsDir "/WeChat_Data"))
      (sloth.concat' sloth.runtimeDir "/doc")
      [
        (sloth.mkdir (sloth.concat' sloth.runtimeDir "/nixpak-${config.flatpak.appId}-tmp"))
        "/tmp"
      ]
    ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
      XDG_DOCUMENTS_DIR = sloth.xdgDocumentsDir;
      # The existing pre-FHS script uses mkdir/ln before /usr/bin exists.
      PATH = lib.makeBinPath [ pkgs.coreutils ];
    };
  };
}
