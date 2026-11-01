# Blender needs GPU access, audio for the sequencer and network for extensions;
# user files are shared through common document directories and the portal.
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
    inputMethod = true;
  };
  desktopIntegration = {
    notifications = true;
    accessibility = true;
  };
  bubblewrap = {
    sockets = {
      x11 = true;
      pulse = true;
    };
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/blender"))
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgPicturesDir
      sloth.xdgVideosDir
    ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
    };
  };
}
