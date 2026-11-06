# Shared policy for game launchers. Every launcher sees the same home:
# ~/Games/home is mounted over $HOME and the real ~/Games at its own path, so
# game data, Proton builds and the umu runtime live in one directory and stay
# where launchers and games expect them. Nothing else in the host home is
# visible. All launchers share that data, so they are one trust domain: keep
# their grants identical here rather than per launcher.
{
  lib,
  sloth,
  ...
}:
let
  gamesDir = sloth.concat' sloth.homeDir "/Games";
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
  portalGroups = {
    openUri = true;
    inhibit = true;
    inputMethod = true;
  };
  bubblewrap = {
    # The home must be mounted before ~/Games and anything else below $HOME.
    bind.rw = lib.mkBefore [
      [
        (sloth.mkdir (sloth.concat' gamesDir "/home"))
        sloth.homeDir
      ]
      gamesDir
    ];
    # Inside the sandbox ~/Games/home is the home itself; hide the loop.
    tmpfs = [ (sloth.concat' gamesDir "/home") ];
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
    };
  };
}
