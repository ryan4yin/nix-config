{
  lib,
  blender,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "org.blender.Blender";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/blender-policy.nix ];
      app = {
        package = blender;
        binPath = "bin/blender";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "blender-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${blender}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "blender";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "blender";
      desktopName = "Blender";
      genericName = "3D Creation Suite";
      comment = "3D modeling, animation and rendering";
      exec = "${exe} %f";
      icon = "blender";
      terminal = false;
      startupNotify = true;
      startupWMClass = "Blender";
      categories = [
        "Graphics"
        "3DGraphics"
      ];
      mimeTypes = [ "application/x-blender" ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
