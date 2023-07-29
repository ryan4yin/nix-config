{ wallpapers, ... }:

{
  home.file.".config/wallpapers".source = wallpapers;
  home.file.".local/bin/wallpaper_random" = {
    source = ./wallpaper_random.py;
    executable = true;
  };
}
