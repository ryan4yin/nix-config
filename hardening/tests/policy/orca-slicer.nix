{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "orca-slicer";
in
mkAppPolicy "orca-slicer" {
  network = "pasta";
  media = false;
  x11 = true;
  notifications = true;
  extraChecks = {
    gdkX11 = app.bubblewrap.env.GDK_BACKEND == "x11";
    webkitDmabuf = app.bubblewrap.env.WEBKIT_DISABLE_DMABUF_RENDERER == "1";
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
  };
}
