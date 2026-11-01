# Minimal local image viewer: no network, audio, camera or notifications.
{
  sloth,
  ...
}:
{
  imports = [ ./desktop-base.nix ];
  portalGroups = {
    fileChooser = true;
    openUri = true;
  };
  bubblewrap = {
    sockets.pulse = false;
    bind.ro = [
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgPicturesDir
    ];
    bind.rw = [ (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/imv")) ];
  };
}
