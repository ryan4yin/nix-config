{
  lib,
  musescore,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "org.musescore.MuseScore";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/musescore-policy.nix ];
      app = {
        package = musescore;
        binPath = "bin/mscore";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "musescore-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${musescore}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "mscore";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = appId;
      desktopName = "MuseScore Studio";
      genericName = "Music Notation";
      comment = "Create, play and print sheet music";
      exec = "${exe} %U";
      icon = "mscore";
      terminal = false;
      startupNotify = true;
      startupWMClass = "MuseScore4";
      categories = [
        "AudioVideo"
        "Audio"
        "Graphics"
        "Midi"
        "Music"
      ];
      mimeTypes = [
        "application/x-musescore"
        "application/x-musescore+xml"
        "application/vnd.recordare.musicxml"
        "application/vnd.recordare.musicxml+xml"
        "audio/midi"
        "x-scheme-handler/musescore"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
