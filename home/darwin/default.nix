{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base/server
      ../base/desktop
      ../base/core.nix
    ];
}
