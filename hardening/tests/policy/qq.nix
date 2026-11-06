{ mkAppPolicy, ... }:
mkAppPolicy "qq" {
  network = "pasta";
  media = true;
  mpris = true;
  notifications = true;
  x11 = true;
  tray = true;
}
