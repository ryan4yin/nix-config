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

        bubblewrap = {
          # To trace all the home files QQ accesses, you can use the following nushell command:
          #   just trace-access qq
          # See the Justfile in the root of this repository for more information.
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
      desktopName = "QQ";
      genericName = "QQ Boxed";
      comment = "Tencent QQ, also known as QQ, is an instant messaging software service and web portal developed by the Chinese technology company Tencent.";
      exec = "${exePath} %U";
      terminal = false;
      icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
      startupNotify = true;
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
