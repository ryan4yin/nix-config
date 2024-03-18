{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    firefox
  ];

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
    vscode = {
      enable = true;
      package = pkgs-unstable.vscode;
      # let vscode sync and update its configuration & extensions across devices, using github account.
      # userSettings = {};
    };
  };
}
