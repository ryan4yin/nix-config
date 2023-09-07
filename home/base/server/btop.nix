{ catppuccin-btop, ... }:

{
  # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  home.file.".config/btop/themes".source = "${catppuccin-btop}/themes";

  # replacement of htop/nmon
  programs.btop = {
    enable = true;
    settings = {
        color_theme = "catppuccin_mocha";
        theme_background = false;   # make btop transparent 
    };
  };
}
