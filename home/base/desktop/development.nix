{  pkgs, nil, ... }:

{
  #############################################################
  #
  #  Basic settings for development environment
  # 
  #  Please avoid to install language specific packages here(globally),
  #  instead, install them independently using dev-templates:
  #     https://github.com/the-nix-way/dev-templates
  #
  #############################################################

  home.packages = with pkgs; [
    nil.packages."${pkgs.system}".default # nix language server

    # IDE
    jetbrains.pycharm-community
    jetbrains.idea-community

    # cloud native
    skopeo
    docker-compose
    dive # explore docker layers
    kubectl
    kubernetes-helm
    terraform
    # terraformer # generate terraform configs from existing cloud resources
    pulumi
    pulumictl
    k9s
    # istioctl

    # cloud provider
    awscli
    aws-iam-authenticator
    eksctl

    # DO NOT install build tools for C/C++, set it per project by devShell instead
    gnumake # used by this repo, to simplify the deployment
    clang-tools
    clang-analyzer

    # Golang
    go
    delve
    gopls

    # Rust
    rustup

    # python
    (python310.withPackages (ps: with ps; [
      ipython
      pandas
      requests
      pyquery
      pyyaml
    ]))

    # db related
    dbeaver
    mycli
    pgcli
    mongosh
    sqlite

    # embedded development
    minicom

    # other tools
    k6 # load testing tool
    mitmproxy # http/https proxy tool
    protobuf # protocol buffer compiler
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = false;
      vimAlias = true;

      # enable line number, disable mouse visual mode
      extraConfig = ''
        set number relativenumber mouse-=a
      '';

    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
