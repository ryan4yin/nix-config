{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "krita";
in
mkAppPolicy "krita" {
  network = "none";
  media = false;
  x11 = false;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    print = app.portalGroups.print;
    inhibit = app.portalGroups.inhibit;
    accessibility = app.desktopIntegration.accessibility;
    qtWayland = app.bubblewrap.env.QT_QPA_PLATFORM == "wayland";
    writableUserDirs = app.fileViewer.writableUserDirs == true;
  };
}
