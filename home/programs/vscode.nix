{
  config,
  pkgs,
  home-manager,
  nix-vscode-extensions,
  ...
}:

{
  programs.vscode = {
    enable = true;

    # let vscode sync and update its configuration & extensions across devices, using github account.

    # userSettings = {};
  };
}