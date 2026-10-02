# - wechat's flatpak manifest: https://github.com/flathub/com.tencent.WeChat/blob/master/com.tencent.WeChat.yaml
# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
#
# We repack WeChat ourselves because nixpkgs' `wechat` package hardcodes its
# AppImage wrapper args and does not expose them for `.override`, so there is no
# way to add our bubblewrap sandbox (bind mounts, tmpfs /home, IME env) through
# it.  We reuse its already-extracted, libtiff-patched AppImage (`wechat.src`),
# so the version and source hash stay maintained by nixpkgs.
# Upstream override support: https://github.com/NixOS/nixpkgs/pull/358977
{
  appimageTools,
  wechat,
}:
let
  pname = "wechat";
  # nixpkgs' wechat package already extracted the AppImage and applied the
  # libtiff.so.5 fix; reuse it so version/hash stay maintained upstream.
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/we/wechat/linux.nix
  appimageContents = wechat.src;
in
appimageTools.wrapAppImage {
  inherit pname;
  inherit (wechat) version;

  src = appimageContents;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/wechat.desktop $out/share/applications/
    mkdir -p $out/share/pixmaps
    cp ${appimageContents}/wechat.png $out/share/pixmaps/

    substituteInPlace $out/share/applications/wechat.desktop --replace-fail AppRun wechat
  '';

  # Add these root paths to FHS sandbox to prevent WeChat from accessing them by default
  # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat-universal.sh?h=wechat-universal-bwrap
  extraPreBwrapCmds = ''
    XDG_DOCUMENTS_DIR="''${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
    if [[ -z "''${XDG_DOCUMENTS_DIR}" ]]; then
        echo 'Error: Failed to get XDG_DOCUMENTS_DIR, refuse to continue'
        exit 1
    fi

    WECHAT_DATA_DIR="''${XDG_DOCUMENTS_DIR}/WeChat_Data"

    # Using ''${WECHAT_DATA_DIR} as Wechat Data folder
    WECHAT_HOME_DIR="''${WECHAT_DATA_DIR}/home"
    WECHAT_FILES_DIR="''${WECHAT_DATA_DIR}/xwechat_files"

    mkdir -p "''${WECHAT_FILES_DIR}"
    mkdir -p "''${WECHAT_HOME_DIR}"
    ln -snf "''${WECHAT_FILES_DIR}" "''${WECHAT_HOME_DIR}/xwechat_files"
  '';
  extraBwrapArgs = [
    "--tmpfs /home"
    "--tmpfs /root"
    # format: --bind <host-path> <sandbox-path>
    "--bind \${WECHAT_HOME_DIR} \${HOME}"
    "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
    "--chdir \${HOME}"
    # wechat-universal only supports xcb
    "--setenv QT_QPA_PLATFORM xcb"
    "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"
    # use fcitx as IME
    "--setenv QT_IM_MODULE fcitx"
    "--setenv GTK_IM_MODULE fcitx"
  ];
  chdirToPwd = false;
  unshareNet = false;
  unshareIpc = true;
  unsharePid = true;
  unshareUts = true;
  unshareCgroup = true;
  privateTmp = true;
}
