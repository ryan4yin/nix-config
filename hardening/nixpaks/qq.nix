# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - QQ's flatpak manifest: https://github.com/flathub/com.qq.QQ/blob/master/com.qq.QQ.yaml
{
  lib,
  qq,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  ...
}:

let
  appId = "com.qq.QQ";

  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        app = {
          package = qq;
          binPath = "bin/qq";
        };
        flatpak.appId = appId;

        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
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
  };
  exePath = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "QQ";
      genericName = "QQ Boxed";
      comment = "Tencent QQ, also known as QQ, is an instant messaging software service and web portal developed by the Chinese technology company Tencent.";
      exec = "${exePath} %U";
      startupNotify = true;
      terminal = false;
      icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
      startupWMClass = "QQ";
      type = "Application";
      categories = [
        "InstantMessaging"
        "Network"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
