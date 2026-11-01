{ mkAppPolicy, ... }:
mkAppPolicy "telegram-desktop" {
  network = "pasta";
  media = true;
  mpris = true;
  notifications = true;
  tray = true;
}
