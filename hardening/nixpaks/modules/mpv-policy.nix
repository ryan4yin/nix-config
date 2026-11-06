# mpv policy: media directories are read-only, playback state and user config
# remain writable, and MPRIS is the only desktop service it owns.
{
  lib,
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
    bind.rw = lib.mkAfter [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/mpv"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.cache/mpv"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/state/mpv"))
      # musicfox dials the hardcoded host /tmp/mpvsocket, so /tmp must be the host's (last bind wins).
      "/tmp"
    ];
    bind.ro = [
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgMusicDir
      sloth.xdgPicturesDir
      sloth.xdgVideosDir
      (sloth.concat' sloth.homeDir "/.config/yt-dlp")
      # go-musicfox hands cached songs to mpv as file:// paths. Nixpak's flatpak
      # shim mounts the app's ~/.var/app cache over ~/.cache, so without this
      # bind every replay fails to load while the first (streamed) play works.
      (sloth.concat' sloth.homeDir "/.cache/go-musicfox")
    ];
  };
}
