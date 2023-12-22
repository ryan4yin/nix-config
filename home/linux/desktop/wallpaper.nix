{wallpapers, ...}: {
  # https://github.com/ryan4yin/wallpapers
  xdg.configFile."wallpapers".source = wallpapers;
  home.file.".local/bin/wallpaper_random" = {
    source = "${wallpapers}/wallpaper_random.py";
    executable = true;
  };
}
