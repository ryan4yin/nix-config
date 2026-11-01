{
  lib,
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
  allowedVideoDevices = [
    "/dev/video0"
    "/dev/video1"
  ];
  notifications = true;
  tray = true;
  extraChecks = {
    fileChooser = app.portalGroups.fileChooser;
    screenCast = app.portalGroups.screenCast;
    camera = app.portalGroups.camera;
    inhibit = app.portalGroups.inhibit;
    accessibility = app.desktopIntegration.accessibility;
    videoDevices = lib.all (dev: lib.elem dev app.bubblewrap.bind.dev) [
      "/dev/video0"
      "/dev/video1"
    ];
    video4linuxSysfs = lib.elem "/sys/class/video4linux" app.bubblewrap.bind.ro;
  };
}
