{
  load,
  mkAppPolicy,
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
  };
}
