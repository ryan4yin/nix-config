{
  lib,
  pkgs,
  imv,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  ...
}:
let
  appId = "com.github.exec64.imv";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/image-viewer-policy.nix ];
      app = {
        package = imv;
        binPath = "bin/imv";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  # Match the upstream imv-dir helper: one file opens its containing directory;
  # multiple arguments are passed through to imv unchanged.
  imvDir = pkgs.writeShellScript "imv-dir" ''
    if [ "$#" -ne 1 ]; then
      exec ${exe} "$@"
    fi
    exec ${exe} -n "$1" "$(${pkgs.coreutils}/bin/dirname "$1")"
  '';
  desktopItem =
    name: desktopName: exec:
    makeDesktopItem {
      inherit name desktopName exec;
      genericName = "Image Viewer";
      comment = "View images";
      icon = "multimedia-photo-viewer";
      terminal = false;
      startupNotify = true;
      startupWMClass = "imv";
      categories = [
        "Graphics"
        "2DGraphics"
        "Viewer"
      ];
      mimeTypes = [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heif"
        "image/jpeg"
        "image/jxl"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ];
      extraConfig.X-Flatpak = appId;
    };
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "imv";
  };
  paths = [
    wrapped.config.script
    (desktopItem "imv" "imv" "${exe} %F")
    (desktopItem "imv-dir" "imv-dir" "${imvDir} %F")
  ];
}
