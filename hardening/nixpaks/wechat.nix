{
  lib,
  bwraps,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.tencent.WeChat";
  # As with Zoom, preserve the outer metadata file across the inner FHS layer.
  # Keep the existing AppImage runtime and WeChat_Data layout unchanged.
  package = bwraps.wechat.overrideAttrs (old: {
    # Refuse unexpected layouts before the existing ln -snf can modify them.
    extraPreBwrapCmds = ''
      wechat_link="''${XDG_DOCUMENTS_DIR}/WeChat_Data/home/xwechat_files"
      wechat_files="''${XDG_DOCUMENTS_DIR}/WeChat_Data/xwechat_files"
      if [[ -e "$wechat_link" || -L "$wechat_link" ]]; then
        if [[ ! -L "$wechat_link" || "$(readlink "$wechat_link")" != "$wechat_files" ]]; then
          echo 'WeChat: unexpected xwechat_files layout; refusing to change existing data.' >&2
          exit 1
        fi
      fi
    ''
    + (old.extraPreBwrapCmds or "");
    extraBwrapArgs = (old.extraBwrapArgs or [ ]) ++ [
      "--ro-bind /.flatpak-info /.flatpak-info"
      # The inner /home reset must not hide an Xauthority file stored there.
      ''--ro-bind-try "''${XAUTHORITY}" "''${XAUTHORITY}"''
    ];
  });
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/wechat-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/wechat";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "wechat-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${package}/share/pixmaps $out/share/pixmaps
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
      icon = "wechat";
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
