{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "imv";
in
mkAppPolicy "imv" {
  network = "none";
  media = false;
  pulse = false;
  x11 = false;
  notifications = false;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    noAudio = !app.bubblewrap.sockets.pulse;
  };
}
