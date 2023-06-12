{ config, pkgs, nil, ... }:

{
  home.packages = with pkgs; [
    nil.packages."${pkgs.system}".default # nix language server

    # GUI IDE
    insomnia # REST client

    # need to run `conda-install` before using it
    # need to run `conda-shell` before using command `conda`
    # conda is not available for MacOS
    conda
  ];

  # GitHub CLI tool
  programs.gh = {
    enable = true;
  };
}
