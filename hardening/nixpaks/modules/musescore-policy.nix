# MuseScore policy: scores and exports use common user directories, audio goes
# through PulseAudio/PipeWire-Pulse, and MIDI uses only the ALSA sequencer node.
{
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
    sockets.pulse = true;
    bind.rw = [
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/MuseScore"))
      (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/MuseScore"))
      sloth.xdgDocumentsDir
      sloth.xdgDownloadDir
      sloth.xdgMusicDir
      sloth.xdgPicturesDir
    ];
    bind.dev = [ "/dev/snd/seq" ];
    # MuseScore 4 is Qt 6; niri has no X server, so use Wayland directly.
    env.QT_QPA_PLATFORM = "wayland";
  };
}
