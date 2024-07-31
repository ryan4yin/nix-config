{
  lib,
  mylib,
  ...
}: {
  imports = mylib.scanPaths ./.;

  virtualisation = {
    docker.enable = lib.mkForce false;
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # Periodically prune Podman resources
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };

    oci-containers = {
      backend = "podman";
    };
  };
}
