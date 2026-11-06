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
    # ~/Games/home is the sandbox home, mounted before ~/Games itself.
    sharedHome =
      lib.take 2 rw == [
        [
          "$HOME/Games/home"
          "$HOME"
        ]
        "$HOME/Games"
      ];
    homeLoopHidden = lib.elem "$HOME/Games/home" (map renderBind app.bubblewrap.tmpfs);
    noXdgStorage = !app.xdgStorage.enable;
    # The only writable host paths are ~/Games and per-app runtime state.
    writableScope = lib.all (
      entry:
      let
        path = source entry;
      in
      path == "$HOME/Games" || lib.hasPrefix "$HOME/Games/" path || lib.hasPrefix "$XDG_RUNTIME_DIR/" path
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
