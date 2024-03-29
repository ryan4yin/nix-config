{
  # Replace dashy with gethomepage, because dashy is too slow to start/reload.

  # # Install the dashy configuration file instead of symlink it
  # system.activationScripts.installDashyConfig = ''
  #   install -Dm 600 ${./dashy_conf.yml} /etc/dashy/dashy_conf.yml
  # '';
  #
  # # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/virtualisation/oci-containers.nix
  # virtualisation.oci-containers.containers = {
  #   # check its logs via `journalctl -u podman-dashy`
  #   dashy = {
  #     hostname = "dashy";
  #     image = "lissy93/dashy:latest";
  #     ports = ["127.0.0.1:4000:80"];
  #     environment = {
  #       "NODE_ENV" = "production";
  #     };
  #     volumes = [
  #       "/etc/dashy/dashy_conf.yml:/app/public/conf.yml"
  #     ];
  #     autoStart = true;
  #     # cmd = [];
  #   };
  # };
}
