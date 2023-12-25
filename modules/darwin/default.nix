{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base.nix
    ];
}
