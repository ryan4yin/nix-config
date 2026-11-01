# Minimal local image viewer. The whole home is read-only so images can be
# opened from any user directory; network, audio and devices stay unavailable.
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
    bind.ro = [ sloth.homeDir ];
  };
}
