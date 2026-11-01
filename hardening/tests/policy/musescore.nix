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
  x11 = true;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    print = app.portalGroups.print;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
    qtXcb = app.bubblewrap.env.QT_QPA_PLATFORM == "xcb";
    alsaSequencer = builtins.elem "/dev/snd/seq" app.bubblewrap.bind.dev;
    alsaPulse = app.bubblewrap.env.ALSA_CONFIG_PATH != "";
    forceAlsa = app.bubblewrap.env.MUSESCORE_FORCE_ALSA == "1";
  };
}
