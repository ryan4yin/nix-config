{
  # Desktops keep X11 forwarding (current behavior, needed for GUI forwarding);
  # servers default to off (see modules/nixos/base/ssh.nix).
  services.openssh.settings.X11Forwarding = true;
}
