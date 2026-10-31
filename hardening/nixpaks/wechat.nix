{
  lib,
  wechat,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.tencent.WeChat";

  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/wechat-policy.nix ];
      app = {
        package = wechat;
        binPath = "bin/wechat";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "wechat-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${wechat}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "wechat";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "wechat";
      desktopName = "WeChat";
      exec = "${exe} %U";
      icon = "${wechat}/share/icons/hicolor/256x256/apps/wechat.png";
      terminal = false;
      startupWMClass = "wechat";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeTypes = [ "x-scheme-handler/weixin" ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
