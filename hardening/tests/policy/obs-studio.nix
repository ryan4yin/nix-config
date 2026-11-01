{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "obs-studio";
in
mkAppPolicy "obs-studio" {
  network = "pasta";
  media = true;
  pulse = true;
  x11 = true;
  notifications = true;
  tray = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    screenCast = app.portalGroups.screenCast;
    camera = app.portalGroups.camera;
    inhibit = app.portalGroups.inhibit;
    accessibility = app.desktopIntegration.accessibility;
  };
}
