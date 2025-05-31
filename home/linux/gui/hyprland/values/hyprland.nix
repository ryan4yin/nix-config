{
  pkgs,
  config,
  lib,
  nur-ryan4yin,
  ...
}: let
  package = pkgs.hyprland;
in {
  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = let
    mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    hyprPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/hyprland/conf";
  in {
    "hypr/configs".source = mkSymlink "${hyprPath}/configs";
    "hypr/mako".source = mkSymlink "${hyprPath}/mako";
    "hypr/scripts".source = mkSymlink "${hyprPath}/scripts";
    "hypr/waybar".source = mkSymlink "${hyprPath}/waybar";
    "hypr/wlogout".source = mkSymlink "${hyprPath}/wlogout";
  };

  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source = let
        configPath = "${config.home.homeDirectory}/.config/hypr/configs";
      in [
        "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes/mocha.conf"
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
      ];
    };
    # gammastep/wallpaper-switcher need this to be enabled.
    systemd = {
      enable = true;
      variables = ["--all"];
    };
  };

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };
}
