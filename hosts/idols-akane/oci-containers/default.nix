{
  mylib,
  lib,
  pkgs,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  virtualisation = {
    docker.enable = true;

    oci-containers = {
      backend = "docker";
    };
  };
}
