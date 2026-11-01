{
  load,
  mkAppPolicy,
  ...
}:
let
  app = load "musescore";
in
mkAppPolicy "musescore" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = false;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    print = app.portalGroups.print;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
    qtWayland = app.bubblewrap.env.QT_QPA_PLATFORM == "wayland";
    alsaSequencer = builtins.elem "/dev/snd/seq" app.bubblewrap.bind.dev;
  };
}
