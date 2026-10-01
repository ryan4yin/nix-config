{ ... }:
{
  ###################################################################################
  #
  #  Containers - Podman
  #
  ###################################################################################

  virtualisation = {
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
        flags = [ "--all" ];
      };
    };

    # Bound container log growth. Podman uses journald when the journal is
    # writable, but rootless sessions can fall back to a file driver
    # (k8s-file / json-file), which otherwise grows without limit.
    containers.containersConf.settings.containers.log_size_max = 10 * 1024 * 1024;
  };
}
