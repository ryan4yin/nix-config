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
    enableNushellIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
}
