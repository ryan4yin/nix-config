{
  mkAppPolicy,
  gamingChecks,
  ...
}:
mkAppPolicy "steam" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  tray = true;
  notifications = false;
  # WA-051: pressure-vessel nests its own bus proxy over nixpak's filtered one
  # and the launcher-service RPC deadlocks, so Steam uses the session bus.
  dbus = false;
  extraChecks = gamingChecks "steam";
}
