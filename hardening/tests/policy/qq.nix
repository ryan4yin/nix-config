{ mkAppPolicy, ... }:
mkAppPolicy "qq" {
  network = "pasta";
  media = true;
  mpris = true;
  notifications = true;
  tray = true;
}
