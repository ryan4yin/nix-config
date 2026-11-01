{
  lib,
  obs-studio,
  obs-studio-plugins,
  wrapOBS,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "com.obsproject.Studio";
  package = wrapOBS.override { inherit obs-studio; } {
    plugins = with obs-studio-plugins; [
      # Wayland screen-capture fallback, per-application audio, and game capture.
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      # Widely used scene, overlay and streaming plugins.
      input-overlay
      obs-multi-rtmp
      obs-shaderfilter
      obs-move-transition
      obs-backgroundremoval
      advanced-scene-switcher
    ];
  };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/obs-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/obs";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "obs-studio-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${package}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "obs";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = appId;
      desktopName = "OBS Studio";
      genericName = "Screen Recorder";
      comment = "Record and stream the desktop";
      exec = "${exe} %U";
      icon = appId;
      terminal = false;
      startupNotify = true;
      startupWMClass = "obs";
      categories = [
        "AudioVideo"
        "Recorder"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
