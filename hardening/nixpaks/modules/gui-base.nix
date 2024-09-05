# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/gui-base.nix
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}: let
  envSuffix = envKey: suffix: sloth.concat' (sloth.env envKey) suffix;
  cursorTheme = pkgs.catppuccin-gtk.override {
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/themes/catppuccin-gtk/default.nix
    accents = ["pink"];
    size = "compact";
    variant = "macchiato";
  };
  iconTheme = pkgs.papirus-icon-theme;
in {
  config = {
    dbus.policies = {
      "${config.flatpak.appId}" = "own";
      "org.freedesktop.DBus" = "talk";
      "org.gtk.vfs.*" = "talk";
      "org.gtk.vfs" = "talk";
      "ca.desrt.dconf" = "talk";
      "org.freedesktop.portal.*" = "talk";
      "org.a11y.Bus" = "talk";
    };
    # https://github.com/nixpak/nixpak/blob/master/modules/gpu.nix
    # 1. bind readonly - /run/opengl-driver
    # 2. bind device   - /dev/dri
    gpu = {
      enable = true;
      provider = "nixos";
      bundlePackage = pkgs.mesa.drivers; # for amd & intel
    };
    # https://github.com/nixpak/nixpak/blob/master/modules/gui/fonts.nix
    fonts.enable = true;
    # https://github.com/nixpak/nixpak/blob/master/modules/locale.nix
    locale.enable = true;
    bubblewrap = {
      network = lib.mkDefault false;
      bind.rw = [
        [
          (envSuffix "HOME" "/.var/app/${config.flatpak.appId}/cache")
          sloth.xdgCacheHome
        ]
        (sloth.concat' sloth.xdgCacheHome "/fontconfig")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")

        (sloth.concat [
          (sloth.env "XDG_RUNTIME_DIR")
          "/"
          (sloth.envOr "WAYLAND_DISPLAY" "no")
        ])

        (envSuffix "XDG_RUNTIME_DIR" "/at-spi/bus")
        (envSuffix "XDG_RUNTIME_DIR" "/gvfsd")
        (envSuffix "XDG_RUNTIME_DIR" "/pulse")
      ];
      bind.ro = [
        "/etc/fonts"
        (envSuffix "XDG_RUNTIME_DIR" "/doc")
        (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
        (sloth.concat' sloth.xdgConfigHome "/fontconfig")
      ];
      env = {
        XDG_DATA_DIRS = lib.mkForce (lib.makeSearchPath "share" [
          pkgs.shared-mime-info
          pkgs.adwaita-icon-theme
          iconTheme
          cursorTheme
        ]);
        XCURSOR_PATH = lib.mkForce (lib.concatStringsSep ":" [
          "${pkgs.adwaita-icon-theme}/share/icons"
          "${pkgs.adwaita-icon-theme}/share/pixmaps"
          "${cursorTheme}/share/icons"
          "${cursorTheme}/share/pixmaps"
          "${iconTheme}/share/icons"
          "${iconTheme}/share/pixmaps"
        ]);
      };
    };
  };
}
