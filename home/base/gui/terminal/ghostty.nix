{
  config,
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Ghostty Configuration
#
# TUIOS provides tabs, panes, scrollback and copy mode, so ghostty
# only needs a font, transparency and the kitty graphics protocol
# (built in).
#
###########################################################
{
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isDarwin then
        null # installed via Homebrew cask on darwin
      else
        pkgs.ghostty;
    enableBashIntegration = false;
    installBatSyntax = false;
    settings = {
      font-family = "Maple Mono NF CN";
      font-size = lib.mkDefault 13; # macOS overrides this in home/darwin/terminal.nix

      # hide title bar/header bar (Linux only; on macOS it would remove the traffic lights too)
      window-decoration = pkgs.stdenv.hostPlatform.isDarwin;

      # transparency
      background-opacity = 0.85;
      background-blur-radius = 10; # macOS only

      # Start fullscreen on macOS; window managers control this on Linux.
      fullscreen = pkgs.stdenv.hostPlatform.isDarwin;

      command = "${lib.getExe config.programs.nushell.package} --config-home ${config.programs.nushell.configDir}";
    };
  };
}
