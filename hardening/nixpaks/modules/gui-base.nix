# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/gui-base.nix
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}: let
  envSuffix = envKey: suffix: sloth.concat' (sloth.env envKey) suffix;
  # cursor & icon's theme should be the same as the host's one.
  cursorTheme = pkgs.bibata-cursors;
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
      enable = lib.mkDefault true;
      provider = "nixos";
      bundlePackage = pkgs.mesa.drivers; # for amd & intel
    };
    # https://github.com/nixpak/nixpak/blob/master/modules/gui/fonts.nix
    # it works not well, bind system's /etc/fonts directly instead
    fonts.enable = false;
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

        "/run/dbus"
      ];
      bind.ro = [
        (envSuffix "XDG_RUNTIME_DIR" "/doc")
        (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
        (sloth.concat' sloth.xdgConfigHome "/fontconfig")

        "/etc/fonts" # for fontconfig
        "/etc/machine-id"
        "/etc/localtime"

        # Fix: libEGL warning: egl: failed to create dri2 screen
        "/etc/egl"
        "/etc/static/egl"
      ];
      bind.dev = [
        # seems required when using nvidia as primary gpu
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-modeset"
        "/dev/nvidia-uvm"
      ];

      env = {
        XDG_DATA_DIRS = lib.mkForce (lib.makeSearchPath "share" [
          iconTheme
          cursorTheme
          pkgs.shared-mime-info
        ]);
        XCURSOR_PATH = lib.mkForce (lib.concatStringsSep ":" [
          "${cursorTheme}/share/icons"
          "${cursorTheme}/share/pixmaps"
        ]);
      };
    };
  };
}
