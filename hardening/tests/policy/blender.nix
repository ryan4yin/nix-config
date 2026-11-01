{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "blender";
in
mkAppPolicy "blender" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
  };
}
