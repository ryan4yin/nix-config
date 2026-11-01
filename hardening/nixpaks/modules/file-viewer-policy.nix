# Shared minimal policy for local file viewers. No network, audio or devices;
# files are opened through the XDG document portal.
{
  lib,
  ...
}:
{
  imports = [ ./desktop-base.nix ];
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
  bubblewrap.sockets.pulse = lib.mkForce false;
}
