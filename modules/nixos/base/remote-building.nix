{username, ...}: {
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
    sshUser = username;
    # ssh key's path on local machine
    sshKey = "/home/${username}/.ssh/ai-idols";
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
    #   # but it seems that it's not used by Nix, takes no effect
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

  # define the host alias for remote builders
  # this config will be written to /etc/ssh/ssh_config
  programs.ssh.extraConfig = ''
    # idols
    Host ai
      HostName 192.168.5.100
      Port 22

    Host aquamarine
      HostName 192.168.5.101
      Port 22

    Host ruby
      HostName 192.168.5.102
      Port 22

    Host kana
      HostName 192.168.5.103
      Port 22

    # rolling girls
    Host nozomi
      HostName 192.168.5.104
      Port 22

    Host yukina
      HostName 192.168.5.105
      Port 22

    Host chiaya
      HostName 192.168.5.106
      Port 22

    Host suzu
      HostName 192.168.5.107
      Port 22
  '';

  # define the host key for remote builders so that nix can verify all the remote builders
  # this config will be written to /etc/ssh/ssh_known_hosts
  programs.ssh.knownHosts = {
    # 星野 愛久愛海, Hoshino Aquamarine
    aquamarine = {
      hostNames = ["aquamarine" "192.168.5.101"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0EzzjnuHBE9xEOZupLmaAj9xbYxkUDeLbMqFZ7YPjU";
    };

    # 星野 瑠美衣, Hoshino Rubii
    ruby = {
      hostNames = ["ruby" "192.168.5.102"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHrDXNQXELnbevZ1rImfXwmQHkRcd3TDNLsQo33c2tUf";
    };

    # 有馬 かな, Arima Kana
    kana = {
      hostNames = ["kana" "192.168.5.103"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMVX05DQD1XJ0AqFZzsRsqgeUOlZ4opAI+8tkVXyjq+";
    };
  };
}
