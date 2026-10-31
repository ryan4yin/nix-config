{
  callPackage,
  mkNixPak,
  google-chrome,
  ...
}:
(callPackage ./modules/chromium-browser.nix { inherit mkNixPak; }) {
  package = google-chrome;
  appId = "com.google.Chrome";
  profile = "google-chrome";
  command = "google-chrome";
  desktopName = "Google Chrome";
  desktopFile = "google-chrome";
  browserpass = true;
  media = true;
  secretPortal = true;
}
