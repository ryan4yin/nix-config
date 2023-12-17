{pkgs, ...}: {
  #============================= Audio(PipeWire) =======================

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pulseaudio # provides `pactl`, which is required by some apps(e.g. sonic-pi)
  ];

  # PipeWire is a new low-level multimedia framework.
  # It aims to offer capture and playback for both audio and video with minimal latency.
  # It support for PulseAudio-, JACK-, ALSA- and GStreamer-based applications.
  # PipeWire has a great bluetooth support, it can be a good alternative to PulseAudio.
  #     https://nixos.wiki/wiki/PipeWire
  services.pipewire = {
    enable = true;
    # package = pkgs-unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = true;
  };
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  sound.enable = false;
  # Disable pulseaudio, it conflicts with pipewire too.
  hardware.pulseaudio.enable = false;

  #============================= Bluetooth =============================

  # enable bluetooth & gui paring tools - blueman
  # or you can use cli:
  # $ bluetoothctl
  # [bluetooth] # power on
  # [bluetooth] # agent on
  # [bluetooth] # default-agent
  # [bluetooth] # scan on
  # ...put device in pairing mode and wait [hex-address] to appear here...
  # [bluetooth] # pair [hex-address]
  # [bluetooth] # connect [hex-address]
  # Bluetooth devices automatically connect with bluetoothctl as well:
  # [bluetooth] # trust [hex-address]
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #================================= Misc =================================

  services = {
    printing.enable = true; # Enable CUPS to print documents.
    geoclue2.enable = true; # Enable geolocation services.

    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
      platformio # udev rules for platformio
      openocd # required by paltformio, see https://github.com/NixOS/nixpkgs/issues/224895
      android-udev-rules # required by adb
      openfpgaloader
    ];

    # A key remapping daemon for linux.
    # https://github.com/rvaiya/keyd
    keyd = {
      enable = true;
      keyboards.default.settings = {
        main = {
          # overloads the capslock key to function as both escape (when tapped) and control (when held)
          capslock = "overload(control, esc)";
        };
      };
    };
  };
}
