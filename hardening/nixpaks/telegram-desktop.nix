{
  lib,
  telegram-desktop,
  buildEnv,
  mkNixPak,
  makeDesktopItem,
  ...
}:
let
  appId = "org.telegram.desktop";
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
        ];
        app.package = telegram-desktop;
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "com.canonical.indicator.application" = "talk";
            "org.ayatana.indicator.application" = "talk";
            "org.sigxcpu.Feedback" = "talk";
          };
        };

        bubblewrap = {
          bind.rw = [
            sloth.xdgDocumentsDir
            sloth.xdgDownloadDir
            sloth.xdgMusicDir
            sloth.xdgVideosDir
            sloth.xdgPicturesDir
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
      desktopName = "Telegram";
      comment = "New era of messaging";
      tryExec = "${exePath}";
      exec = "${exePath} -- %u";
      icon = appId;
      startupNotify = true;
      startupWMClass = appId;
      terminal = false;
      type = "Application";
      categories = [
        "Chat"
        "Network"
        "InstantMessaging"
        "Qt"
      ];
      mimeTypes = [
        "x-scheme-handler/tg"
        "x-scheme-handler/tonsite"
      ];
      keywords = [
        "tg"
        "chat"
        "im"
        "messaging"
        "messenger"
        "sms"
        "tdesktop"
      ];
      actions = {
        quit = {
          name = "Quit Telegram";
          exec = "${exePath} -quit";
          icon = "application-exit";
        };
      };
      extraConfig = {
        X-Flatpak = appId;
        DBusActivatable = "true";
        SingleMainWindow = "true";
        X-GNOME-UsesNotifications = "true";
        X-GNOME-SingleWindow = "true";
      };
    })
  ];
}
