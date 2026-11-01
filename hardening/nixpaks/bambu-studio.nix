{
  lib,
  bambu-studio,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.bambulab.BambuStudio";
  package = bambu-studio;

  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/slicer-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/bambu-studio";
      };
      flatpak = { inherit appId; };
      # Work around wxWidgets HiDPI text clipping under fractional scaling.
      # https://github.com/bambulab/BambuStudio/issues/4959
      bubblewrap.env.GDK_DPI_SCALE = "0.8";
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "bambu-studio-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${package}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "bambu-studio";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "com.bambulab.BambuStudio";
      desktopName = "BambuStudio";
      genericName = "3D Printing Software";
      comment = "PC software for BambuLab 3D printers";
      exec = "${exe} %U";
      icon = "BambuStudio";
      terminal = false;
      startupWMClass = "bambu-studio";
      categories = [
        "Graphics"
        "3DGraphics"
        "Engineering"
      ];
      mimeTypes = [
        "model/stl"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "application/x-amf"
        "x-scheme-handler/bambustudio"
        "model/step"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
