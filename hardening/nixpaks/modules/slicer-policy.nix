# Shared policy for the wxWidgets/GTK3 slicers. Both applications are X11-only
# and use pasta networking for cloud services and LAN printer discovery.
{
  config,
  lib,
  sloth,
  ...
}:
let
  cfg = config.slicer;
in
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  options.slicer.enablePulse = lib.mkEnableOption "PulseAudio for Bambu printer video preview";
  config = {
    pasta.mode = "isolate";
    bubblewrap = {
      sockets = {
        x11 = true;
        pulse = lib.mkForce cfg.enablePulse;
      };
      env = {
        DISPLAY = sloth.envOr "DISPLAY" "";
        XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
        GDK_BACKEND = "x11";
      };
      # File-manager launches pass host paths into the sandbox. Slicers both read
      # models and write sliced output, so give the common document directories
      # read-write access; the file chooser still handles other locations.
      bind.rw = [
        sloth.xdgDocumentsDir
        sloth.xdgDownloadDir
        sloth.xdgPicturesDir
      ];
    };
    portalGroups = {
      fileChooser = true;
      openUri = true;
      notifications = true;
      inputMethod = true;
    };
    desktopIntegration = {
      notifications = true;
      accessibility = true;
    };
  };
}
