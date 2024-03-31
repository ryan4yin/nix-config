{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../../../../secrets/nixos.nix
      ../../../../modules/nixos/base/ssh.nix
      ../../../../modules/nixos/base/user-group.nix
      ../../../../modules/base.nix
    ];

  modules.secrets.server.network.enable = true;

  microvm = {
    mem = 1024; # RAM allocation in MB
    vcpu = 1; # Number of Virtual CPU cores

    interfaces = [
      {
        type = "tap";
        id = "vm-suzi"; # should be prefixed with "vm-"
        mac = "02:00:00:00:00:01"; # unique MAC address
      }
    ];

    # Block device images for persistent storage
    # microvm use tmpfs for root(/), so everything else
    # is ephemeral and will be lost on reboot.
    #
    # you can check this by running `df -Th` & `lsblk` in the VM.
    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 512;
      }
      {
        mountPoint = "/etc";
        image = "etc.img";
        size = 50;
      }
    ];

    # shares can not be set to `neededForBoot = true;`
    # so if you try to use a share in boot script(such as system.activationScripts), it will fail!
    shares = [
      {
        # It is highly recommended to share the host's nix-store
        # with the VMs to prevent building huge images.
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        #
        # by this way, /nix/store is readonly in the VM,
        # and thus the VM can't run any command that modifies
        # the store. such as nix build, nix shell, etc...
        # if you want to run nix commands in the VM, see
        # https://github.com/astro/microvm.nix/blob/main/doc/src/shares.md#writable-nixstore-overlay
        tag = "ro-store"; # Unique virtiofs daemon tag
        proto = "virtiofs"; # virtiofs is faster than 9p
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    hypervisor = "qemu";
    # Control socket for the Hypervisor so that a MicroVM can be shutdown cleanly
    socket = "control.socket";
  };

  system.stateVersion = "23.11";
}
