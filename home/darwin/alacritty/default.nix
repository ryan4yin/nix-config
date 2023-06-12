{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;
  xdg.configFile."alacritty/theme_github_dark.yml".source = ./theme_github_dark.yml;
}
