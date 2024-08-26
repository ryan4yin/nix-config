{
  mylib,
  lib,
  ...
}: {
  imports = mylib.scanPaths ./.;
}
