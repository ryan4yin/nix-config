{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "remmina";
in
mkAppPolicy "remmina" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = false;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    openUri = app.portalGroups.openUri;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
    sshAgent = app.remoteDesktop.sshAgent;
  };
}
