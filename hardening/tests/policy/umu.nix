{
  lib,
  load,
  mkAppPolicy,
  renderBind,
  ...
}:
let
  app = load "umu";
  rw = map renderBind app.bubblewrap.bind.rw;
  source = entry: if builtins.isList entry then builtins.head entry else entry;
in
mkAppPolicy "umu" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  notifications = false;
  extraChecks = {
    # ~/Gaming is the sandbox home and the only writable host path besides
    # per-app runtime state.
    sharedHome = lib.elem [
      "$HOME/Gaming"
      "$HOME"
    ] rw;
    noXdgStorage = !app.xdgStorage.enable;
    writableScope = lib.all (
      entry:
      let
        path = source entry;
      in
      path == "$HOME/Gaming" || lib.hasPrefix "$XDG_RUNTIME_DIR/" path
    ) rw;
    gamepadsOnly =
      lib.elem [
        "/dev/gamepad-input"
        "/dev/input"
      ] app.bubblewrap.bind.dev
      && !lib.elem "/dev/input" app.bubblewrap.bind.dev
      && !lib.any (path: lib.hasPrefix "/dev/hidraw" path) (lib.flatten app.bubblewrap.bind.dev);
    driver32 = lib.elem "/run/opengl-driver-32" app.bubblewrap.bind.ro;
    protonPath = lib.hasPrefix builtins.storeDir app.bubblewrap.env.UMU_PROTONPATH;
    openUri = app.portalGroups.openUri;
    noFileChooser = !app.portalGroups.fileChooser;
  };
}
