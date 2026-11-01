# OBS capture policy: screen/camera access stays on the XDG portals, audio goes
# through PulseAudio/PipeWire-Pulse, and network access is pasta-isolated.
{
  sloth,
  ...
}:
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  pasta.mode = "isolate";
  portalGroups = {
    fileChooser = true;
    openUri = true;
    notifications = true;
    screenCast = true;
    camera = true;
    inhibit = true;
    inputMethod = true;
  };
  desktopIntegration = {
    notifications = true;
    tray = true;
    accessibility = true;
  };
  bubblewrap = {
    sockets = {
      x11 = true;
      pulse = true;
    };
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/obs-studio"))
      sloth.xdgVideosDir
      sloth.xdgPicturesDir
      sloth.xdgDownloadDir
    ];
    # OBS enumerates DRM connectors when building its encoder list.
    bind.ro = [ "/sys/class/drm" ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
    };
  };
}
