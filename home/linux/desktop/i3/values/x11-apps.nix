{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
  ];

  # TODO vscode & chrome both have wayland support, but they don't work with fcitx5, need to fix it.
  programs = {
    # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    google-chrome = {
      enable = true;

      # chrome wayland support was broken on nixos-unstable branch, so fallback to stable branch for now
      # https://github.com/swaywm/sway/issues/7562
      package = pkgs.google-chrome;

      # commandLineArgs = [
      # ];
    };
  };
}
