{
  pkgs,
  lib,
  ...
}:
{
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

  home.packages =
    with pkgs;
    [
      colmena # nixos's remote deployment tool

      # db related
      # mycli
      pgcli
      sqlite

      # spreadsheets / data files: interactive viewer for csv, xlsx, tsv, json, sqlite
      visidata

      # embedded development
      minicom

      # ai related
      python313Packages.huggingface-hub # huggingface-cli
      yt-dlp # youtube/bilibili/soundcloud/... video/music downloader

      # Automatically trims your branches whose tracking remote refs are merged or gone
      # It's really useful when you work on a project for a long time.
      git-trim
    ]
    # conda is not available on macOS
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # need to run `conda-install` before using it
      # need to run `conda-shell` before using command `conda`
      conda
    ];

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
