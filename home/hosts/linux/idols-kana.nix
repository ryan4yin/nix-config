{
  imports = [
    ../../linux/core.nix
    ../../linux/gui/i3
  ];

  # Headless X11/i3 session for computer use.
  modules.desktop.computerUse.enable = true;
  # localhost-only VNC server for manual access (use an SSH tunnel).
  modules.desktop.computerUse.vnc = true;
}
