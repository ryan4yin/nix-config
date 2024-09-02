{
  lib,
  pkgs,
  mkNixPak,
  nixpak-pkgs,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app = {
      package = pkgs.qq.override {
        # fix fcitx5 input method
        commandLineArgs = lib.concatStringsSep " " ["--enable-wayland-ime"];
      };
      binPath = "bin/qq";
    };
    flatpak.appId = "com.tencent.qq";

    imports = [
      "${nixpak-pkgs}/pkgs/modules/gui-base.nix"
      "${nixpak-pkgs}/pkgs/modules/network.nix"
    ];

    # list all dbus services:
    #   ls -al /run/current-system/sw/share/dbus-1/services/
    #   ls -al /etc/profiles/per-user/ryan/share/dbus-1/services/
    dbus.policies = {
      "org.gnome.Shell.Screencast" = "talk";
      "org.freedesktop.Notifications" = "talk";
      "org.kde.StatusNotifierWatcher" = "talk";
    };
    bubblewrap = {
      bind.rw = [
        (sloth.concat [sloth.xdgConfigHome "/QQ"])
        (sloth.mkdir (sloth.concat [sloth.xdgDownloadDir "/QQ"]))
      ];
      bind.ro = [
        "/etc/fonts"
        "/etc/machine-id"
        "/etc/localtime"
        "/run/opengl-driver"
      ];
      network = true;
      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/dri"
        "/dev/shm"
        "/run/dbus"

        "/dev/nvidia-uvm" # required when using nvidia as primary gpu
      ];
      tmpfs = [
        "/tmp"
      ];
      env = {
        XDG_DATA_DIRS = lib.mkForce (lib.makeSearchPath "share" (with pkgs; [
          adw-gtk3
          tela-icon-theme
          shared-mime-info
        ]));
        XCURSOR_PATH = lib.mkForce (lib.concatStringsSep ":" (with pkgs; [
          "${tela-icon-theme}/share/icons"
          "${tela-icon-theme}/share/pixmaps"
          "${simp1e-cursors}/share/icons"
          "${simp1e-cursors}/share/pixmaps"
        ]));
      };
    };
  };
}
