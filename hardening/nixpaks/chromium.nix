{
  callPackage,
  mkNixPak,
  chromium,
  ...
}:
(callPackage ./modules/chromium-browser.nix { inherit mkNixPak; }) {
  package = chromium;
  appId = "org.chromium.Chromium";
  profile = "chromium";
  command = "chromium";
  desktopName = "Chromium";
  desktopFile = "chromium-browser";
  browserpass = true;
  media = true;
  hostLoopback = true;
  personalFiles = true;
  secretPortal = true;
}
