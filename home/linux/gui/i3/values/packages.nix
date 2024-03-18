{pkgs, ...}: {
  home.packages = with pkgs; [
    # required by https://github.com/adi1090x/polybar-themes
    rofi # application launcher, the same as dmenu
    polybar # status bar
    pywal # generate color scheme from wallpaper
    calc
    networkmanager_dmenu # network manager

    dunst # notification daemon
    i3lock # default i3 screen locker
    xautolock # lock screen after some time
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
