{
  pkgs,
  config,
  ...
}: {
  # hyprland configs, based on https://github.com/notwidow/hyprland
  home.file.".config/hypr" = {
    source = ./hypr-conf;
    # copy the scripts directory recursively
    recursive = true;
  };

	home.packages = with pkgs; [
    waybar        # for the status bar
    swaybg        # for setting the wallpaper
    swayidle      # for setting the idle timeout
    swaylock      # for locking the screen
    wl-clipboard  # for copying and pasting
    wf-recorder   # for screen recording

    xfce.xfce4-appfinder  # for the application launcher

    wofi      # for the application launcher
    mako      # for the notification daemon
    grim      # for taking screenshots
    slurp     # for selecting a region to screenshot

    light    # for changing the screen brightness
    yad      # for the brightness popup

    # 用于播放系统音效
    mpd      # for playing system sounds
    mpc-cli  # command-line mpd client
    ncmpcpp  # a mpd client with a UI
    
    viewnior  # Elegant Image Viewer 
	];
}