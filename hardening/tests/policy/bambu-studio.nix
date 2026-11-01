{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "bambu-studio";
in
mkAppPolicy "bambu-studio" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  notifications = true;
  extraChecks = {
    gdkX11 = app.bubblewrap.env.GDK_BACKEND == "x11";
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
  };
}
