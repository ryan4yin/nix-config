{ ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/virtualisation/oci-containers.nix
  virtualisation.oci-containers.containers = {
    # check its logs via `journalctl -u podman-uptime-kuma`
    #
    # The data lives in a podman *named volume*: podman creates it and takes
    # the ownership from the image, so no host directory or tmpfiles rule is
    # needed (the volume is under /var/lib/containers, which preservation
    # already keeps).
    uptime-kuma = {
      hostname = "uptime-kuma";
      image = "docker.io/louislam/uptime-kuma:1";
      ports = [ "127.0.0.1:53350:3001" ];
      volumes = [ "uptime-kuma-data:/app/data" ];
      autoStart = true;
    };
  };
}
