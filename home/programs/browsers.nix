{
  pkgs,
  nixpkgs-stable,
  config,
  ...
}: let
  pkgs-stable = import nixpkgs-stable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  in {
  home.packages = with pkgs-stable; [
    firefox-wayland

    # chrome wayland support was broken on nixos-unstable branch, so fallback to stable branch for now
    # https://github.com/swaywm/sway/issues/7562
    google-chrome
  ];

  programs.vscode = {
    enable = true;
    package = pkgs-stable.vscode;  # use the stable version

    # let vscode sync and update its configuration & extensions across devices, using github account.
    # userSettings = {};
  };
}
