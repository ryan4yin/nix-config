{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base
    ];
}
