{
  mylib,
  lib,
  ...
}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../../../hardening/firejail
    ];
}
