{ mylib, pkgs, ... }:
{
  # wayland related
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
    # enable native Wayland support for most Electron apps
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # Make Qt apps follow the GTK font and theme. Without this, Qt keeps its
    # built-in default ("Sans Serif" 9) while GTK uses `gtk-font-name`
    # (Noto Sans 11), so Qt apps like Telegram render visibly smaller than
    # GTK apps. The `gtk3` platform theme plugin ships with qtbase, so no
    # extra package is needed, and it also gets GTK file dialogs.
    "QT_QPA_PLATFORMTHEME" = "gtk3";
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
    # syncthing.enable = true;
  };
}
