{
  lib,
  mpv,
  mpvScripts,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  ...
}:
let
  appId = "io.mpv.Mpv";
  package = mpv.override { scripts = [ mpvScripts.mpris ]; };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/mpv-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/mpv";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "mpv";
  };
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = "mpv";
      desktopName = "mpv Media Player";
      genericName = "Media Player";
      comment = "Play audio and video files";
      exec = "${exe} --player-operation-mode=pseudo-gui -- %U";
      icon = "mpv";
      terminal = false;
      startupNotify = true;
      startupWMClass = "mpv";
      categories = [
        "AudioVideo"
        "Audio"
        "Video"
        "Player"
      ];
      mimeTypes = [
        "application/ogg"
        "application/x-matroska"
        "audio/flac"
        "audio/mpeg"
        "audio/ogg"
        "audio/wav"
        "video/mp4"
        "video/quicktime"
        "video/webm"
        "video/x-matroska"
        "video/x-msvideo"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
