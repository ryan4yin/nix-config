{pkgs, ...}: {
  home.packages = with pkgs; [
    rofi # application launcher, the same as dmenu
    dunst # notification daemon
    i3blocks # status bar
    i3lock # default i3 screen locker
    xautolock # lock screen after some time
    i3status # provide information to i3bar
    i3-gaps # i3 with gaps
    picom # transparency and shadows
    feh # set wallpaper
    xcolor # color picker
    xsel # for clipboard support in x11, required by tmux's clipboard support

    acpi # battery information
    arandr # screen layout manager
    dex # autostart applications
    xbindkeys # bind keys to commands
    xorg.xbacklight # control screen brightness, the same as light
    xorg.xdpyinfo # get screen information
    scrot # minimal screen capture tool, used by i3 blur lock to take a screenshot
    sysstat # get system information
    alsa-utils # provides amixer/alsamixer/...
  ];
}
