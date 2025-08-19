{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./anyrun.nix
  ];

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

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/base/desktop/conf";
    in
    {
      "mako".source = mkSymlink "${confPath}/mako";
      "waybar".source = mkSymlink "${confPath}/waybar";
      "wlogout".source = mkSymlink "${confPath}/wlogout";
      "hypr/hypridle.conf".source = mkSymlink "${confPath}/hypridle.conf";
    };

  # status bar
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
  # Disable catppuccin to avoid conflict with my non-nix config.
  catppuccin.waybar.enable = false;

  # screen locker
  programs.swaylock.enable = true;

  # Logout Menu
  programs.wlogout.enable = true;
  catppuccin.wlogout.enable = false;

  # Hyprland idle daemon
  services.hypridle.enable = true;

  # notification daemon, the same as dunst
  services.mako.enable = true;
  catppuccin.mako.enable = false;
}
