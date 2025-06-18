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
      # System tray icon
      "org.freedesktop.Notifications" = "talk";
      "org.kde.StatusNotifierWatcher" = "talk";
      # File Manager
      "org.freedesktop.FileManager1" = "talk";
      # Uses legacy StatusNotifier implementation
      "org.kde.*" = "own";
    };
    bubblewrap = {
      # To trace all the home files QQ accesses, you can use the following nushell command:
      #   just trace-access qq
      # See the Justfile in the root of this repository for more information.
      bind.rw = [
        # given the read write permission to the following directories.
        # NOTE: sloth.mkdir is used to create the directory if it does not exist!
        (sloth.mkdir (sloth.concat [sloth.xdgConfigHome "/QQ"]))

        sloth.xdgDocumentsDir
        sloth.xdgDownloadDir
        sloth.xdgMusicDir
        sloth.xdgVideosDir
      ];
      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
    };
  };
}
