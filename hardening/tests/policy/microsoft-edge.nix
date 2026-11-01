{ mkAppPolicy, ... }:
mkAppPolicy "microsoft-edge" {
  network = "pasta";
  media = false;
  mpris = false;
  notifications = true;
  personalFiles = false;
  browserpass = false;
  secretPortal = true;
}
