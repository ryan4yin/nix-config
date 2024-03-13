{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}: {
  # terminal file manager
  programs.yazi = {
    enable = true;
    package = pkgs-unstable.yazi;
    # Changing working directory when exiting Yazi
    enableBashIntegration = true;
    # TODO: nushellIntegration is broken on release-23.11, wait for master's fix to be released
    enableNushellIntegration = false;
  };

  xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
}
