# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - QQ's flatpak manifest: https://github.com/flathub/com.qq.QQ/blob/master/com.qq.QQ.yaml
{
  lib,
  pkgs,
  mkNixPak,
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
      ./modules/gui-base.nix
      ./modules/network.nix
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
      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/shm" # Shared Memory

        # seems required when using nvidia as primary gpu
        "/dev/nvidia0"
        "/dev/nvidia-uvm"
        "/dev/nvidia-modeset"
      ];
      tmpfs = [
        "/tmp"
      ];
    };
  };
}
