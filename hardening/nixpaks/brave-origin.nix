{
  callPackage,
  mkNixPak,
  brave-origin,
  ...
}:
(callPackage ./modules/chromium-browser.nix { inherit mkNixPak; }) {
  package = brave-origin;
  appId = "com.brave.Origin";
  profile = "BraveSoftware/Brave-Origin";
  command = "brave-origin";
  desktopName = "Brave Origin";
  desktopFile = "brave-origin";
  browserpass = false;
  secretPortal = true;
}
