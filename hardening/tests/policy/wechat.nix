{ mkAppPolicy, ... }:
mkAppPolicy "wechat" {
  network = "pasta";
  media = true;
  mpris = false;
  notifications = false;
  x11 = true;
  tray = true;
}
