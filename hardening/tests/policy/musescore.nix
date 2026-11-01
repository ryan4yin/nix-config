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
  pulse = false;
  allowPipewire = true;
  x11 = true;
  notifications = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    print = app.portalGroups.print;
    inputMethod = app.portalGroups.inputMethod;
    accessibility = app.desktopIntegration.accessibility;
    qtXcb = app.bubblewrap.env.QT_QPA_PLATFORM == "xcb";
    alsaSequencer = builtins.elem "/dev/snd/seq" app.bubblewrap.bind.dev;
    hostAlsaConfig =
      builtins.elem "/etc/alsa" app.bubblewrap.bind.ro
      && builtins.elem "/etc/static/alsa" app.bubblewrap.bind.ro;
    pipewireAudio = app.bubblewrap.sockets.pipewire;
    forceAlsa = app.bubblewrap.env.MUSESCORE_FORCE_ALSA == "1";
  };
}
