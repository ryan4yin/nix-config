# MuseScore policy: scores and exports use common user directories, audio goes
# through PulseAudio/PipeWire-Pulse, and MIDI uses only the ALSA sequencer node.
{
  pkgs,
  sloth,
  ...
}:
let
  # MuseScore has PipeWire and ALSA audio backends, but not a native
  # PulseAudio one. Route ALSA's default PCM through the confined PulseAudio
  # socket instead of exposing raw PipeWire or /dev/snd PCM devices.
  alsaConfig = pkgs.writeText "musescore-alsa.conf" ''
    pcm_type.pulse {
      libs.native = "${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so";
    }
    ctl_type.pulse {
      libs.native = "${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so";
    }
    pcm.!default {
      type pulse
    }
    ctl.!default {
      type pulse
    }
  '';
in
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  pasta.mode = "isolate";
  portalGroups = {
    fileChooser = true;
    openUri = true;
    notifications = true;
    print = true;
    inputMethod = true;
  };
  desktopIntegration = {
    notifications = true;
    accessibility = true;
  };
  bubblewrap = {
    sockets = {
      # MuseScore 4's nixpkgs launcher selects Qt's XCB backend. Niri provides
      # that through XWayland, so expose the X11 socket and credentials.
      x11 = true;
      pulse = true;
    };
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/MuseScore"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/MuseScore"))
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgMusicDir
      sloth.xdgPicturesDir
    ];
    bind.dev = [ "/dev/snd/seq" ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
      QT_QPA_PLATFORM = "xcb";
      ALSA_CONFIG_PATH = "${alsaConfig}";
      MUSESCORE_FORCE_ALSA = "1";
    };
  };
}
