# - Nixpkgs: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/we/wechat/package.nix
# - wechat's flatpak manifest: https://github.com/flathub/com.tencent.WeChat/blob/master/com.tencent.WeChat.yaml
# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
#
# TODO Since appimageTools.wrapAppImage do not support overriding, I have to pack this package myself.
# https://github.com/NixOS/nixpkgs/pull/358977
{
  appimageTools,
  fetchurl,
}: let
  pname = "wechat";
  version = "4.0.1.11";
  src = fetchurl {
    url = "https://web.archive.org/web/20250512110825if_/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    hash = "sha256-gBWcNQ1o1AZfNsmu1Vi1Kilqv3YbR+wqOod4XYAeVKo=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage {
    inherit pname version src;

    # Add these root paths to FHS sandbox to prevent WeChat from accessing them by default
    # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat-universal.sh?h=wechat-universal-bwrap
    extraPreBwrapCmds = ''
      XDG_DOCUMENTS_DIR="''${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
      if [[ -z "''${XDG_DOCUMENTS_DIR}" ]]; then
          echo 'Error: Failed to get XDG_DOCUMENTS_DIR, refuse to continue'
          exit 1
      fi

      WECHAT_DATA_DIR="''${XDG_DOCUMENTS_DIR}/WeChat_Data"
      WECHAT_FILES_DIR="''${WECHAT_DATA_DIR}/xwechat_files"
      WECHAT_HOME_DIR="''${WECHAT_DATA_DIR}/home"

      mkdir -p "''${WECHAT_FILES_DIR}"
      mkdir -p "''${WECHAT_HOME_DIR}"
    '';
    extraBwrapArgs = [
      "--tmpfs /home"
      "--tmpfs /root"
      "--bind \${WECHAT_HOME_DIR} \${HOME}"
      "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
      "--chdir $HOME"
      "--setenv QT_QPA_PLATFORM xcb"
      "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"
    ];
    chdirToPwd = false;
    unshareNet = false;
    unshareIpc = true;
    unsharePid = true;
    unshareUts = true;
    unshareCgroup = true;
    privateTmp = true;

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/wechat.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/wechat.png $out/share/pixmaps/

      substituteInPlace $out/share/applications/wechat.desktop --replace-fail AppRun wechat
    '';
  }
