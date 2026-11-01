{
  lib,
  load,
  mkAppPolicy,
  ...
}:
let
  zoom = load "zoom";
in
mkAppPolicy "zoom" {
  network = "pasta";
  media = true;
  mpris = false;
  notifications = false;
  x11 = true;
  tray = true;
  allowedVideoDevices = [
    "/dev/video0"
    "/dev/video1"
  ];
  extraChecks = {
    drmSysfs = lib.elem "/sys/class/drm" zoom.bubblewrap.bind.ro;
    videoDevices = lib.all (dev: lib.elem dev zoom.bubblewrap.bind.dev) [
      "/dev/video0"
      "/dev/video1"
    ];
  };
}
