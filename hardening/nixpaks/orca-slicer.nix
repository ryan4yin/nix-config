{
  lib,
  orca-slicer,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.orcaslicer.OrcaSlicer";
  package = orca-slicer;

  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/slicer-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/orca-slicer";
      };
      flatpak = { inherit appId; };
      # WebKitGTK's DMA-BUF renderer produces a blank home page under
      # XWayland on NVIDIA; force the software path like Bambu does.
      bubblewrap.env.WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "orca-slicer-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${package}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "orca-slicer";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "com.orcaslicer.OrcaSlicer";
      desktopName = "OrcaSlicer";
      genericName = "3D Printing Software";
      comment = "G-code generator for 3D printers";
      exec = "${exe} %U";
      icon = "OrcaSlicer";
      terminal = false;
      startupWMClass = "orca-slicer";
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
        "x-scheme-handler/orcaslicer"
        "model/step"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
