# Zoom keeps the upstream FHS runtime inside the outer nixpak boundary.
{ lib, sloth, ... }:
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
  bubblewrap = {
    # ZoomLauncher selects xcb; the X11 connection retains X11's display trust.
    sockets.x11 = true;
    # Nixpak emits tmpfs after socket binds; a /tmp tmpfs would hide X11.
    # The outer sandbox root already provides a private, ephemeral /tmp.
    tmpfs = lib.mkForce [ "/dev/shm" ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
    };
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.zoom"))
      (sloth.concat' sloth.xdgConfigHome "/zoomus.conf")
      (sloth.concat' sloth.xdgConfigHome "/zoom.conf")
      (sloth.mkdir (sloth.concat' sloth.xdgDocumentsDir "/Zoom"))
      sloth.xdgDownloadDir
    ];
  };
}
