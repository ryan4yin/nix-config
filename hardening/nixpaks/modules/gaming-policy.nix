# Shared policy for game launchers. Every launcher sees the same home: ~/Gaming
# is mounted over $HOME, so game installs (~/Gaming/Games, the sandbox's
# ~/Games where launchers put them by default), Proton builds, the umu runtime
# and saves all live in that one directory. Nothing else in the host home is
# visible. All launchers share that data, so they are one trust domain: keep
# their grants identical here rather than per launcher.
{
  lib,
  pkgs,
  sloth,
  ...
}:
let
  # The FHS layers Steam, Heroic and umu build have their own /etc/fonts, whose
  # config lists neither the host fonts nor their own /usr/share/fonts, so the
  # CJK fonts in those layers were never scanned (Steam rendered tofu). Point
  # fontconfig at the layer's own font directory instead.
  fontsConf = pkgs.writeText "gaming-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">/etc/fonts/conf.d</include>
      <dir>/usr/share/fonts</dir>
      <dir prefix="xdg">fonts</dir>
      <cachedir prefix="xdg">fontconfig</cachedir>
    </fontconfig>
  '';
in
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  # Games write saves straight into $HOME (~/.factorio, ~/.renpy, ...), which
  # per-app XDG directories would silently discard on exit.
  xdgStorage.enable = false;
  pasta.mode = "isolate";
  # Steam and Heroic register a StatusNotifierItem for their tray icon; without
  # these grants the desktop shell has nothing to show for it (the same reason
  # WeChat's tray icon needed them).
  desktopIntegration.tray = true;
  portalGroups = {
    openUri = true;
    inhibit = true;
    inputMethod = true;
  };
  bubblewrap = {
    bind.rw = [
      [
        (sloth.mkdir (sloth.concat' sloth.homeDir "/Gaming"))
        sloth.homeDir
      ]
    ];
    # Wine and the Steam client talk X11 (XWayland).
    sockets.x11 = true;
    bind.ro = [
      # 32-bit games and Proton's 32-bit half; nixpak maps only the 64-bit
      # /run/opengl-driver.
      "/run/opengl-driver-32"
      # pressure-vessel resolves the user and D-Bus needs a machine ID. The
      # buildFHSEnv layer takes both from this /etc.
      "/etc/passwd"
      "/etc/group"
      "/etc/machine-id"
      # Flatpak's --device=all sysfs set minus /sys/block: Wine reads the CPU
      # topology from /sys/devices/system/cpu, and SDL, Wine's winebus and
      # pressure-vessel enumerate GPUs and controllers through sysfs and udev.
      "/sys/bus"
      "/sys/class"
      "/sys/dev"
      "/sys/devices"
      "/run/udev/data"
      "/run/udev/control"
    ];
    # Joystick evdev nodes only, hard-linked by the host udev rules in
    # ../default.nix; the whole /dev/input would expose every keyboard.
    bind.dev = [
      [
        "/dev/gamepad-input"
        "/dev/input"
      ]
    ];
    env = {
      DISPLAY = sloth.envOr "DISPLAY" "";
      XAUTHORITY = sloth.envOr "XAUTHORITY" (sloth.concat' sloth.homeDir "/.Xauthority");
      # Proton builds that Steam offers per game and protontricks resolves, as
      # programs.steam.extraCompatPackages would set. Store paths: a game can
      # read them but not modify them. DW-Proton is WA-019.
      FONTCONFIG_FILE = lib.mkForce "${fontsConf}";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = lib.makeSearchPathOutput "steamcompattool" "" [
        pkgs.dwproton-bin
        pkgs.proton-ge-bin
      ];
    };
  };
}
