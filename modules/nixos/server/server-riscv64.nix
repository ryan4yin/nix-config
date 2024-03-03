{pkgs, ...}: {
  # =========================================================================
  #      Base NixOS Configuration
  # =========================================================================

  imports = [
    ../base/core.nix
    ../base/i18n.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/ssh.nix
    ../base/user-group.nix

    ../../base.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim

    # networking
    mtr # A network diagnostic tool
    iperf3 # A tool for measuring TCP and UDP bandwidth performance
    nmap # A utility for network discovery and security auditing
    ldns # replacement of dig, it provide the command `drill`
    socat # replacement of openbsd-netcat
    tcpdump # A powerful command-line packet analyzer

    # archives
    zip
    xz
    unzip
    p7zip
    zstd
    gnutar

    # misc
    file
    which
    tree
    gnused
    gawk
    zellij
    docker-compose
  ];

  virtualisation.docker = {
    enable = true;
    # start dockerd on boot.
    # This is required for containers which are created with the `--restart=always` flag to work.
    enableOnBoot = true;
  };
}
