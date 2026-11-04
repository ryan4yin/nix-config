{ mkAppPolicy, ... }:
mkAppPolicy "chromium" {
  network = "host";
  media = true;
  mpris = true;
  notifications = true;
  personalFiles = true;
  browserpass = true;
  secretPortal = true;
  fido2 = true;
}
