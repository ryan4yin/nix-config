# MuseScore policy: scores and exports use common user directories. Audio uses
# ALSA via the host PipeWire plugin, MIDI uses the ALSA sequencer, and the UI
# runs through XWayland.
{
  lib,
  sloth,
  ...
}:
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
      # MuseScore speaks ALSA; the host ALSA configuration forwards its
      # default PCM to PipeWire, so expose the PipeWire socket for audio.
      pulse = lib.mkForce false;
      pipewire = lib.mkForce true;
    };
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/MuseScore"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/MuseScore"))
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgMusicDir
      sloth.xdgPicturesDir
    ];
    # Use the host's ALSA configuration, which routes the default PCM
    # through PipeWire. Only the sequencer node is needed for MIDI.
    bind.ro = [
      "/etc/alsa"
      "/etc/static/alsa"
    ];
    bind.dev = [ "/dev/snd/seq" ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
      QT_QPA_PLATFORM = "xcb";
      MUSESCORE_FORCE_ALSA = "1";
    };
  };
}
