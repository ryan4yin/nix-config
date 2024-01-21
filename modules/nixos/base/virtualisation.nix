{pkgs, ...}: {
  ###################################################################################
  #
  #  Visualisation - Libvirt(QEMU/KVM) / Docker / LXD / WayDroid
  #
  ###################################################################################

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        # enables pulling using containerd, which supports restarting from a partial pull
        # https://docs.docker.com/storage/containerd/
        "features" = {"containerd-snapshotter" = true;};
      };

      # start dockerd on boot.
      # This is required for containers which are created with the `--restart=always` flag to work.
      enableOnBoot = true;
    };

    waydroid.enable = true;
    lxd.enable = true;
  };
}
