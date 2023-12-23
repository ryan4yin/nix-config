{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    // [
      ../base/desktop
      ../base/core.nix
    ];
}
