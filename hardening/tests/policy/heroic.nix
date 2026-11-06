{
  mkAppPolicy,
  gamingChecks,
  ...
}:
mkAppPolicy "heroic" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  notifications = false;
  extraChecks = gamingChecks "heroic";
}
