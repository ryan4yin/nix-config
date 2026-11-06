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
  extraChecks = gamingChecks "steam";
}
