{pkgs, ...}: {

  # =========================================================================
  #      Base NixOS Configuration
  # =========================================================================

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    # Manual optimise storage: nix-store --optimise
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    auto-optimise-store = true;
    builders-use-substitutes = true;
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #
  # TODO feel free to add or remove packages here.
  environment.systemPackages = with pkgs; [
    neovim

    # networking
    mtr      # A network diagnostic tool
    iperf3   # A tool for measuring TCP and UDP bandwidth performance
    nmap     # A utility for network discovery and security auditing
    ldns     # replacement of dig, it provide the command `drill`
    socat    # replacement of openbsd-netcat
    tcpdump  # A powerful command-line packet analyzer

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
    tmux
    docker-compose
  ];

  # replace default editor with neovim
  environment.variables.EDITOR = "nvim";

  virtualisation.docker = {
    enable = true;
    # start dockerd on boot.
    # This is required for containers which are created with the `--restart=always` flag to work.
    enableOnBoot = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password";  # disable root login with password
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };
}
