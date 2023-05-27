{config, pkgs, nil, ...}: 

{
  home.packages = with pkgs; [
    nil.packages."${pkgs.system}".default  # nix language server

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

    # DO NOT install build tools for C/C++, set it per project by devShell instead
    gnumake  # used by this repo, to simplify the deployment
    clang-tools
    clang-analyzer
    # lldb
    # cmake
    # autoconf
    # automake
    # bison
    # cppcheck
    # fakeroot
    # flex
    # gettext
    # groff
    # libtool
    # m4
    # patch
    # pkgconf
    # texinfo
    # binutils

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

    # python
    (python3.withPackages(ps: with ps; [
      ipython
      pandas
      requests
      pyquery
    ]))
    # need to run `conda-install` before using it
    # need to run `conda-shell` before using command `conda`
    conda

    # db related
    dbeaver
    mycli
    pgcli

    # embedded development
    minicom
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      extraConfig = ''
        set number relativenumber
      '';
    };

    direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    };
  };

  # GitHub CLI tool
  programs.gh = {
    enable = true;
  };
}