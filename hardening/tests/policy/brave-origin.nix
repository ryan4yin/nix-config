{ mkAppPolicy, ... }:
mkAppPolicy "brave-origin" {
  network = "pasta";
  media = false;
  mpris = false;
  notifications = true;
  personalFiles = false;
  browserpass = false;
  secretPortal = true;
}
