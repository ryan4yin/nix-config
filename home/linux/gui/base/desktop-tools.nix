{ mylib, pkgs, ... }:
{
  # wayland related
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
    # enable native Wayland support for most Electron apps
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # Make Qt apps follow the system light/dark live. Noctalia's theme mode
    # writes org.gnome.desktop.interface color-scheme, and this platform theme
    # (shipped by qtbase) reads it over the XDG desktop portal.
    # Do not switch to `gtk3`: it would align Qt's font with `gtk-font-name`
    # (Noto Sans 11), but GTK3 has no dynamic dark/light signal, so Qt apps like
    # Telegram would be stuck on the light palette. Qt's default font stays
    # "Sans Serif" 9; only a font-providing theme can change that size.
    "QT_QPA_PLATFORMTHEME" = "xdgdesktopportal";
    # misc
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "GDK_BACKEND" = "wayland";
    "XDG_SESSION_TYPE" = "wayland";
  };

  home.packages = with pkgs; [
    wl-clipboard # copying and pasting
    brightnessctl
    # screen recording
    wf-recorder # screen recording

    virt-manager # manage the libvirt VMs
    virt-viewer # vnc/spice console for the libvirt VMs
  ];

  # Emergency session-menu fallback; the normal flow uses Noctalia's session panel.
  programs.wlogout.enable = true;

  # auto mount usb drives
  services = {
    udiskie.enable = true;
  };
}
