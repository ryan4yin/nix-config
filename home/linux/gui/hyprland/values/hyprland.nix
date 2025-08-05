{
  pkgs,
  pkgs-stable,
  config,
  ...
}:
let
  package = pkgs.hyprland;
in
{
  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      hyprPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/hyprland/conf";
    in
    {
      "mako".source = mkSymlink "${hyprPath}/mako";
      "waybar".source = mkSymlink "${hyprPath}/waybar";
      "wlogout".source = mkSymlink "${hyprPath}/wlogout";
      "hypr/hypridle.conf".source = mkSymlink "${hyprPath}/hypridle.conf";
      "hypr/configs".source = mkSymlink "${hyprPath}/configs";
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

  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source =
        let
          configPath = "${config.home.homeDirectory}/.config/hypr/configs";
        in
        [
          "${configPath}/exec.conf"
          "${configPath}/fcitx5.conf"
          "${configPath}/keybindings.conf"
          "${configPath}/settings.conf"
          "${configPath}/windowrules.conf"
        ];
      env = [
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "XDG_SESSION_TYPE,wayland"
      ];
    };
    # gammastep/wallpaper-switcher need this to be enabled.
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
  };

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };
}
