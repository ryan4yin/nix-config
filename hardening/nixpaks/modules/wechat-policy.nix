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
    # Preserve X11's socket; the sandbox root still supplies private /tmp.
    tmpfs = lib.mkForce [ "/dev/shm" ];
    # libdbus aborts without a machine ID; use an app-specific synthetic ID.
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
