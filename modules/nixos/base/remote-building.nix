{myvars, ...}: {
  ####################################################################
  #
  #  NixOS's Configuration for Remote Building / Distributed Building
  #
  #  Related Docs:
  #    1. https://github.com/NixOS/nix/issues/7380
  #    2. https://nixos.wiki/wiki/Distributed_build
  #    3. https://github.com/NixOS/nix/issues/2589
  #
  ####################################################################

  # set local's max-job to 0 to force remote building(disable local building)
  # nix.settings.max-jobs = 0;
  nix.distributedBuilds = true;
  nix.buildMachines = let
    sshUser = myvars.username;
    # ssh key's path on local machine
    sshKey = "/etc/agenix/ssh-key-romantic";
    systems = [
      # native arch
      "x86_64-linux"

      # emulated arch using binfmt_misc and qemu-user
      "aarch64-linux"
      "riscv64-linux"
    ];
    # all available system features are poorly documentd here:
    #  https://github.com/NixOS/nix/blob/e503ead/src/libstore/globals.hh#L673-L687
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "kvm"
    ];
  in [
    # Nix seems always try to build on the machine remotely
    # to make use of the local machine's high-performance CPU, do not set remote builder's maxJobs too high.
    # {
    #   # some of my remote builders are running NixOS
    #   # and has the same sshUser, sshKey, systems, etc.
    #   inherit sshUser sshKey systems supportedFeatures;
    #
    #   # the hostName should be:
    #   #   1. a hostname that can be resolved by DNS
    #   #   2. the ip address of the remote builder
    #   #   3. a host alias defined globally in /etc/ssh/ssh_config
    #   hostName = "aquamarine";
    #   # remote builder's max-job
    #   maxJobs = 3;
    #   # speedFactor's a signed integer
    #   # https://github.com/ryan4yin/nix-config/issues/70
    #   speedFactor = 1;
    # }
    # {
    #   inherit sshUser sshKey systems supportedFeatures;
    #   hostName = "ruby";
    #   maxJobs = 2;
    #   speedFactor = 1;
    # }
    # {
    #   inherit sshUser sshKey systems supportedFeatures;
    #   hostName = "kana";
    #   maxJobs = 2;
    #   speedFactor = 1;
    # }
  ];
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
