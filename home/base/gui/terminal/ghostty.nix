{
  pkgs,
  ghostty,
  ...
}:
###########################################################
#
# Ghostty Configuration
#
###########################################################
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty; # the stable version
    # package = ghostty.packages.${pkgs.system}.default; # the latest version
    enableBashIntegration = true;
    # installVimSyntax = true;
    settings = {
      theme = "catppuccin-mocha";

      font-family = "JetBrains Mono";
      font-size = 13;

      background-opacity = 0.93;
      # only supported on macOS;
      background-blur-radius = 10;
      scrollback-limit = 20000;
    };
  };
}
