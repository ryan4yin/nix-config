{
  pkgs,
  pkgs-unstable,
  ...
}: {
  #############################################################
  #
  #  Basic settings for development environment
  #
  #  Please avoid to install language specific packages here(globally),
  #  instead, install them:
  #     1. per IDE, such as `programs.neovim.extraPackages`
  #     2. per-project, using https://github.com/the-nix-way/dev-templates
  #
  #############################################################

  home.packages = with pkgs;
    [
      colmena # nixos's remote deployment tool

      # db related
      dbeaver
      mycli
      pgcli
      mongosh
      sqlite

      # embedded development
      minicom

      # ai related
      python311Packages.huggingface-hub # huggingface-cli

      # misc
      pkgs-unstable.devbox
      bfg-repo-cleaner # remove large files from git history
      k6 # load testing tool
      protobuf # protocol buffer compiler

      # solve coding extercises - learn by doing
      exercism
    ]
    ++ (
      lib.optionals pkgs.stdenv.isLinux [
        # Automatically trims your branches whose tracking remote refs are merged or gone
        # It's really useful when you work on a project for a long time.
        git-trim

        # need to run `conda-install` before using it
        # need to run `conda-shell` before using command `conda`
        # conda is not available for MacOS
        conda

        mitmproxy # http/https proxy tool
        insomnia # REST client
        wireshark # network analyzer
        ventoy # create bootable usb
      ]
    );

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
