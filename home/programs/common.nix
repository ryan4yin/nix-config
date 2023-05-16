{pkgs, config, ...}: 


{
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep
    yq-go    # https://github.com/mikefarah/yq
    htop
    iotop
    iftop
    nmon

    ## networking tools
    wireshark
    wireguard-tools  # manage wireguard vpn manually, via wg-quick

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils

    # productivity
    obsidian
    hugo

    # IDE
    insomnia
    jetbrains.pycharm-community
    # jetbrains.idea-community

    # cloud native
    docker-compose
    kubectl
    kubernetes-helm
    terraform
    pulumi

    # cloud provider
    awscli

    # C
    clang-tools
    clang-analyzer
    lldb
    gnumake
    cmake
    autoconf
    automake
    bison
    cppcheck
    fakeroot
    flex
    gettext
    groff
    libtool
    m4
    patch
    pkgconf
    texinfo
    binutils


    # Golang
    delve
    go
    go-outline
    go-tools
    go2nix
    gomodifytags
    gopls
    gotests
    impl

    # Rust
    rustup

    # nodejs
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn

    # db related
    dbeaver
    mycli
    pgcli

    # instant messaging
    telegram-desktop
    discord
    qq      # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/networking/instant-messengers/qq

    # music
    musescore

    # system call monitoring
    strace
    ltrace  # library call monitoring
    lsof
    mtr
  ];

  programs = {
    # A terminal multiplexer
    tmux = {
      enable = true;
    };

    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;  # set nvim as default editor
      extraConfig = ''
        set number relativenumber
      '';
    };

    # a cat(1) clone with syntax highlighting and Git integration.
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Catppuccin-mocha";
      };
      themes = {
        Catppuccin-mocha = builtins.readFile (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme";
          hash = "sha256-qMQNJGZImmjrqzy7IiEkY5IhvPAMZpq0W6skLLsng/w=";
        });
      };
    };

    btop.enable = true;  # replacement of htop/nmon
    exa.enable = true;   # A modern replacement for ‘ls’
    jq.enable = true;    # A lightweight and flexible command-line JSON processor
    ssh.enable = true;
    aria2.enable = true;  # a 

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  services = {
    # syncthing.enable = true;

    # auto mount usb drives
    udiskie.enable = true;
  };
}
