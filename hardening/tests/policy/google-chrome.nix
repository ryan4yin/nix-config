{ mkAppPolicy, ... }:
mkAppPolicy "google-chrome" {
  network = "pasta";
  media = true;
  mpris = true;
  notifications = true;
  personalFiles = false;
  browserpass = true;
  secretPortal = true;
}
