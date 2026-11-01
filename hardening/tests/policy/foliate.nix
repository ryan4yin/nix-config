{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "foliate";
in
mkAppPolicy "foliate" {
  network = "none";
  media = false;
  x11 = false;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
  };
}
