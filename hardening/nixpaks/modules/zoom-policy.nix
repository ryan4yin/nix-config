# Zoom keeps the upstream FHS runtime inside the outer nixpak boundary.
{ lib, sloth, ... }:
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  pasta.mode = "isolate";
  desktopIntegration.tray = true;
  portalGroups = {
    fileChooser = true;
    openUri = true;
    notifications = true;
    screenCast = true;
    camera = true;
    inhibit = true;
    inputMethod = true;
  };
  bubblewrap = {
    # Screen sharing enumerates DRM connectors through sysfs. Missing this
    # directory makes Zoom abort with std::filesystem_error.
    bind.ro = [ "/sys/class/drm" ];
    # ZoomLauncher selects xcb; the X11 connection retains X11's display trust.
    sockets.x11 = true;
    # desktop-base supplies the app-specific /tmp; X11 binds are nested into it.
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
    };
    bind.dev = [
      # Zoom 7.2.1 still opens V4L2 device nodes directly for webcam capture.
      "/dev/video0"
      "/dev/video1"
    ];
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.zoom"))
      (sloth.concat' sloth.xdgConfigHome "/zoomus.conf")
      (sloth.concat' sloth.xdgConfigHome "/zoom.conf")
      (sloth.mkdir (sloth.concat' sloth.xdgDocumentsDir "/Zoom"))
      sloth.xdgDownloadDir
    ];
  };
}
