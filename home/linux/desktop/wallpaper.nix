{ wallpapers, ... }:

{
  # https://github.com/ryan4yin/wallpapers
  home.file.".config/wallpapers".source = wallpapers;
  home.file.".local/bin/wallpaper_random" = {
    source = "${wallpapers}/wallpaper_random.py";
    executable = true;
  };
}
