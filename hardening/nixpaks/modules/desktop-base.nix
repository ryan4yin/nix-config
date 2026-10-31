# Shared desktop runtime. Applications opt into portal and native desktop
# services separately. No host GVfs, shared caches, raw camera or PipeWire socket.
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}:
{
  imports = [
    ./portal-groups.nix
    ./desktop-integration.nix
  ];
  gpu = {
    enable = lib.mkDefault true;
    provider = "nixos";
    bundlePackage = pkgs.mesa.drivers;
  };
  fonts = {
    enable = true;
    # Preserve nixpak's default coverage and add Chinese/Japanese/Korean glyphs.
    fonts = with pkgs; [
      cantarell-fonts
      dejavu_fonts
      liberation_ttf
      gyre-fonts
      source-sans
      source-code-pro
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
  };
  locale.enable = true;
  dbus = {
    policies = {
      "${config.flatpak.appId}" = "own";
      "${config.flatpak.appId}.*" = "own";
    };
    rules.call."org.freedesktop.portal.Desktop" = [
      "org.freedesktop.DBus.Properties.Get@/org/freedesktop/portal/desktop"
      "org.freedesktop.DBus.Properties.GetAll@/org/freedesktop/portal/desktop"
      "org.freedesktop.portal.Settings.Read@/org/freedesktop/portal/desktop"
      "org.freedesktop.portal.Settings.ReadAll@/org/freedesktop/portal/desktop"
      "org.freedesktop.portal.Request.Close@/org/freedesktop/portal/desktop/request/*"
      "org.freedesktop.portal.Session.Close@/org/freedesktop/portal/desktop/session/*"
    ];
    rules.broadcast."org.freedesktop.portal.Desktop" = [
      "org.freedesktop.portal.Settings.SettingChanged@/org/freedesktop/portal/desktop"
      "@/org/freedesktop/portal/desktop/*"
    ];
  };
  bubblewrap = {
    network = lib.mkDefault false;
    newSession = true;
    dieWithParent = true;
    clearEnv = true;
    sockets = {
      wayland = true;
      x11 = lib.mkDefault false;
      pulse = lib.mkDefault true;
      pipewire = false;
    };
    bind.rw = with sloth; [
      [
        (mkdir appCacheDir)
        xdgCacheHome
      ]
      [
        (mkdir appConfigDir)
        xdgConfigHome
      ]
      [
        (mkdir appDataDir)
        xdgDataHome
      ]
      [
        (mkdir (concat' appDir "/state"))
        xdgStateHome
      ]
      (concat' runtimeDir "/doc")
      # Chrome/Firefox/Telegram/etc. use /tmp for single-instance IPC. Share
      # this directory across launches of the same app only; app IDs differ.
      [
        (mkdir (concat' runtimeDir "/nixpak-${config.flatpak.appId}-tmp"))
        "/tmp"
      ]
    ];
    bind.ro = [
      "/etc/localtime"
      "/etc/zoneinfo"
      (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
      (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
      "/sys/devices/platform"
    ]
    ++ lib.optionals config.gpu.enable [
      "/etc/egl"
      "/etc/static/egl"
    ];
    # nixpak's NixOS GPU provider maps DRM nodes, but NVIDIA also needs its
    # dedicated interfaces. Missing nodes are skipped by --dev-bind-try.
    bind.dev = lib.optionals config.gpu.enable [
      "/dev/nvidia0"
      "/dev/nvidiactl"
      "/dev/nvidia-modeset"
      "/dev/nvidia-uvm"
    ];
    tmpfs = [
      "/dev/shm"
    ];
    env = {
      HOME = sloth.homeDir;
      USER = sloth.env "USER";
      XDG_RUNTIME_DIR = sloth.runtimeDir;
      XDG_CACHE_HOME = sloth.xdgCacheHome;
      XDG_CONFIG_HOME = sloth.xdgConfigHome;
      XDG_DATA_HOME = sloth.xdgDataHome;
      XDG_STATE_HOME = sloth.xdgStateHome;
      XDG_SESSION_TYPE = "wayland";
      WAYLAND_DISPLAY = sloth.envOr "WAYLAND_DISPLAY" "wayland-0";
      NIXOS_OZONE_WL = "1";
      GTK_USE_PORTAL = "1";
      GTK_A11Y = sloth.envOr "GTK_A11Y" "0";
      XDG_DATA_DIRS = lib.makeSearchPath "share" [
        pkgs.papirus-icon-theme
        pkgs.bibata-cursors
        pkgs.shared-mime-info
      ];
      XCURSOR_PATH = "${pkgs.bibata-cursors}/share/icons:${pkgs.bibata-cursors}/share/pixmaps";
      # Point fontconfig at the configuration mounted by nixpak fonts.enable.
      FONTCONFIG_FILE = "/etc/fonts/fonts.conf";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
    }
    // lib.genAttrs [
      "LANG"
      "LANGUAGE"
      "LC_ALL"
      "LC_ADDRESS"
      "LC_COLLATE"
      "LC_CTYPE"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MESSAGES"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
      "XCURSOR_THEME"
      "XCURSOR_SIZE"
      "NO_AT_BRIDGE"
      "QT_QPA_PLATFORMTHEME"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION"
    ] (name: sloth.envOr name "");
  };
}
