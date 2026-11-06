{
  load,
  mkAppPolicy,
  renderBind,
  ...
}:
let
  app = load "mpv";
in
mkAppPolicy "mpv" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = false;
  mpris = true;
  notifications = false;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    # The flatpak shim hides ~/.cache, so the musicfox cache must be bound back.
    musicfoxCache = builtins.elem "$HOME/.cache/go-musicfox" (map renderBind app.bubblewrap.bind.ro);
  };
}
