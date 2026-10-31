{
  callPackage,
  mkNixPak,
  microsoft-edge,
  ...
}:
(callPackage ./modules/chromium-browser.nix { inherit mkNixPak; }) {
  package = microsoft-edge;
  appId = "com.microsoft.Edge";
  profile = "microsoft-edge";
  command = "microsoft-edge";
  desktopName = "Microsoft Edge";
  desktopFile = "microsoft-edge";
  browserpass = false;
  secretPortal = true;
  privateWindowFlag = "--inprivate";
}
