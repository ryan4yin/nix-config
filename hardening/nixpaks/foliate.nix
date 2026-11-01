{
  lib,
  foliate,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.github.johnfactotum.Foliate";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/file-viewer-policy.nix ];
      app = {
        package = foliate;
        binPath = "bin/foliate";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "foliate-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${foliate}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "foliate";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "com.github.johnfactotum.Foliate";
      desktopName = "Foliate";
      genericName = "E-Book Viewer";
      comment = "Read e-books in style";
      exec = "${exe} %U";
      icon = "com.github.johnfactotum.Foliate";
      terminal = false;
      startupNotify = true;
      startupWMClass = "com.github.johnfactotum.Foliate";
      categories = [
        "Office"
        "Viewer"
      ];
      mimeTypes = [
        "application/epub+zip"
        "application/x-mobipocket-ebook"
        "application/vnd.amazon.mobi8-ebook"
        "application/x-fictionbook+xml"
        "application/x-zip-compressed-fb2"
        "application/vnd.comicbook+zip"
        "x-scheme-handler/opds"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
