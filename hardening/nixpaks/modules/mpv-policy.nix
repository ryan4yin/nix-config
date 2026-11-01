# mpv policy: media directories are read-only, playback state and user config
# remain writable, and MPRIS is the only desktop service it owns.
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
  };
  desktopIntegration.mpris = true;
  bubblewrap = {
    sockets.pulse = true;
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/mpv"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.cache/mpv"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/state/mpv"))
    ];
    bind.ro = [
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgMusicDir
      sloth.xdgPicturesDir
      sloth.xdgVideosDir
      (sloth.concat' sloth.homeDir "/.config/yt-dlp")
    ];
  };
}
