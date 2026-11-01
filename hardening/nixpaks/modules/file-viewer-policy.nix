# Shared minimal policy for local file viewers. No network, audio or devices;
# files selected through the desktop portal, plus common user document folders
# for direct file-manager launches.
{
  config,
  lib,
  sloth,
  ...
}:
let
  cfg = config.fileViewer;
  userDirs = [
    sloth.xdgDocumentsDir
    sloth.xdgDownloadDir
    sloth.xdgPicturesDir
  ];
in
{
  imports = [ ./desktop-base.nix ];
  options.fileViewer.writableUserDirs = lib.mkEnableOption ''
    writing to Documents, Downloads and Pictures for apps that save edits
  '';
  config = {
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
      sockets.pulse = lib.mkForce false;
      bind.ro = lib.mkIf (!cfg.writableUserDirs) userDirs;
      bind.rw = lib.mkIf cfg.writableUserDirs userDirs;
    };
  };
}
