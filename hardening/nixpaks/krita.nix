{
  lib,
  krita,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "org.kde.krita";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/file-viewer-policy.nix ];
      app = {
        package = krita;
        binPath = "bin/krita";
      };
      flatpak = { inherit appId; };
      # Qt defaults to xcb when DISPLAY is present in the parent environment;
      # niri has no X server, so select Wayland explicitly.
      bubblewrap.env.QT_QPA_PLATFORM = "wayland";
      # Krita saves edits in place, so the common user directories are writable.
      fileViewer.writableUserDirs = true;
      # Printing and sleep inhibition are explicit Krita capabilities.
      portalGroups = {
        print = true;
        inhibit = true;
      };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "krita-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${krita}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "krita";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "org.kde.krita";
      desktopName = "Krita";
      genericName = "Digital Painting";
      comment = "Digital painting and illustration";
      exec = "${exe} %F";
      icon = "krita";
      terminal = false;
      startupNotify = true;
      startupWMClass = "krita";
      categories = [
        "Qt"
        "KDE"
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
      ];
      mimeTypes = [
        "application/x-krita"
        "image/openraster"
        "application/x-krita-paintoppreset"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
