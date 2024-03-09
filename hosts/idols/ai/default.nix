{vars_networking, ...}:
#############################################################
#
#  Ai - my main computer, with NixOS + I5-13600KF + RTX 4090 GPU, for gaming & daily use.
#
#############################################################
let
  hostName = "ai"; # Define your hostname.
  hostAddress = vars_networking.hostAddress.${hostName};
in {
  imports = [
    ./cifs-mount.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./impermanence.nix
    ./secureboot.nix
  ];

  networking = {
    inherit hostName;
    inherit (vars_networking) defaultGateway nameservers;

    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = false;
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [hostAddress];
    };
  };

  # conflict with feature: containerd-snapshotter
  # virtualisation.docker.storageDriver = "btrfs";

  # for Nvidia GPU
  services.xserver.videoDrivers = ["nvidia"]; # will install nvidia-vaapi-driver by default
  hardware.nvidia = {
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;

    # required by most wayland compositors!
    modesetting.enable = true;
    powerManagement.enable = true;
  };
  virtualisation.docker.enableNvidia = true; # for nvidia-docker

  hardware.opengl = {
    enable = true;
    # if hardware.opengl.driSupport is enabled, mesa is installed and provides Vulkan for supported hardware.
    driSupport = true;
    # needed by nvidia-docker
    driSupport32Bit = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
