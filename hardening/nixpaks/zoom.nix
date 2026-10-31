{
  lib,
  zoom-us,
  buildFHSEnv,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "us.zoom.Zoom";
  # Keep the upstream FHS wrapper, including its /opt mount and launcher. Its
  # automatic root mounts only copy directories, so preserve nixpak's metadata
  # file explicitly for portal identification from inside the nested sandbox.
  package = zoom-us.override {
    xdgDesktopPortalSupport = true;
    buildFHSEnv =
      args:
      buildFHSEnv (
        args
        // {
          extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [
            "--ro-bind /.flatpak-info /.flatpak-info"
          ];
        }
      );
  };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/zoom-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/zoom";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "zoom-desktop-assets" { } ''
    mkdir -p $out/share
    for directory in icons pixmaps; do
      if [ -d ${package}/share/$directory ]; then
        ln -s ${package}/share/$directory $out/share/$directory
      fi
    done
  '';
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = "Zoom";
      desktopName = "Zoom Workplace";
      comment = "Zoom Video Conference";
      exec = "${exe} %U";
      icon = "Zoom";
      terminal = false;
      startupWMClass = "zoom";
      categories = [ "Network" ];
      mimeTypes = [
        "x-scheme-handler/zoommtg"
        "x-scheme-handler/zoomus"
        "application/x-zoom"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
