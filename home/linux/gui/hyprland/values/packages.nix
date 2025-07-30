{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    swaybg # the wallpaper
    wl-clipboard # copying and pasting
    hyprpicker # color picker
    brightnessctl

    hyprshot # screen shot
    wf-recorder # screen recording

    # audio
    alsa-utils # provides amixer/alsamixer/...
    networkmanagerapplet # provide GUI app: nm-connection-editor
  ];
}
