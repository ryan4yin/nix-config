# Fork of nixpak/pkgs's gui-base.nix: the shared GUI runtime plumbing (GPU,
# fonts, desktop caches, /dev/shm, and the audio/display sockets) that lets a
# GUI app run under bubblewrap. Paths bound here must not be bound again in
# ./custom-policy.nix or the app configs: nixpak emits read-only binds last, so
# a duplicate read-only bind would silently shadow a writable one.
#
# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/gui-base.nix
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}:
let
  envSuffix = envKey: suffix: sloth.concat' (sloth.env envKey) suffix;
  # nixpak cannot pass a variable only when it is set, so an unset one arrives
  # empty; only list variables whose readers treat empty as unset.
  passHostEnv = names: lib.genAttrs names (name: sloth.envOr name "");
  # cursor & icon's theme should be the same as the host's one.
  cursorTheme = pkgs.bibata-cursors;
  iconTheme = pkgs.papirus-icon-theme;
in
{
  config = {
    dbus.policies = {
      "${config.flatpak.appId}" = "own";
      # we add other policies in ./custom-policy.nix
    };
    # https://github.com/nixpak/nixpak/blob/master/modules/gpu.nix
    # The NixOS provider exposes host drivers at /run/opengl-driver (read-only)
    # and all /dev/dri nodes (device access), including Intel, AMD and Asahi DRM devices.
    # Nixpak also maps /sys/dev/char and /sys/devices/pci0000:00 read-only for discovery.
    # These mappings grant access; they do not select the GPU used by an application.
    gpu = {
      enable = lib.mkDefault true;
      provider = "nixos";
      bundlePackage = pkgs.mesa.drivers;
    };
    # https://github.com/nixpak/nixpak/blob/master/modules/gui/fonts.nix
    # it works not well, bind system's /etc/fonts directly instead
    fonts.enable = false;
    # https://github.com/nixpak/nixpak/blob/master/modules/locale.nix
    locale.enable = true;
    bubblewrap = {
      # Nixpak uses --ro-bind-try / --dev-bind-try: absent host paths are skipped,
      # so shared mappings work on Intel/NVIDIA hosts and Apple Silicon alike.
      network = lib.mkDefault false;
      # setsid keeps the app off the launching terminal (TIOCSTI), and the
      # sandbox goes down with the launcher instead of outliving it.
      newSession = true;
      dieWithParent = true;

      # nixpak binds sockets read-only, which is sufficient: connect() only needs
      # the socket inode's write bit, and the kernel's read-only-filesystem check
      # does not apply to sockets. Every app here is Wayland-only, so X11 stays
      # disabled (the nixpak default, spelled out for intent) and PipeWire is
      # shared for screensharing.
      sockets = {
        wayland = true;
        pipewire = true;
        pulse = true;
        x11 = false;
      };

      bind.rw = [
        [
          (envSuffix "HOME" "/.var/app/${config.flatpak.appId}/cache")
          sloth.xdgCacheHome
        ]
        (sloth.concat' sloth.xdgCacheHome "/fontconfig")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")

        # gvfsd is a directory that holds FUSE mounts, not a socket, so it must
        # stay writable.
        (envSuffix "XDG_RUNTIME_DIR" "/gvfsd")
      ];
      bind.ro = [
        # Sockets only need to be connectable, and connect() works on a read-only
        # bind (see the note on `sockets` above).
        (envSuffix "XDG_RUNTIME_DIR" "/at-spi/bus")

        (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
        (sloth.concat' sloth.xdgConfigHome "/fontconfig")

        "/etc/fonts" # for fontconfig
        "/etc/localtime" # this is a symlink to /etc/zoneinfo/xxx
        "/etc/zoneinfo"

        # Host EGL configuration (read-only); needed by some driver setups.
        "/etc/egl"
        "/etc/static/egl"

        # Asahi GPU discovery follows /sys/dev/char links into platform devices.
        # Expose their targets read-only; this includes non-GPU platform metadata too.
        "/sys/devices/platform"
      ];
      bind.dev = [
        "/dev/shm" # Shared Memory

        # Additional NVIDIA interfaces, retained for primary-GPU and offload use.
        # Unlike /dev/dri above, numbered NVIDIA nodes are not mapped as a directory.
        "/dev/nvidia0" # GPU index 0; additional GPUs need explicit mappings.
        "/dev/nvidiactl" # Driver control interface.
        "/dev/nvidia-modeset" # Display mode setting.
        "/dev/nvidia-uvm" # Unified virtual memory.
      ];

      tmpfs = [
        "/tmp"
      ];

      # Start from an empty environment so host secrets (tokens, credentials)
      # stay outside; everything the apps need is listed here.
      clearEnv = true;
      env = {
        HOME = sloth.homeDir;
        USER = sloth.env "USER";
        XDG_RUNTIME_DIR = sloth.runtimeDir;
        XDG_CACHE_HOME = sloth.xdgCacheHome;
        XDG_CONFIG_HOME = sloth.xdgConfigHome;
        XDG_DATA_HOME = sloth.xdgDataHome;
        XDG_STATE_HOME = sloth.xdgStateHome;
        # Same fallback as nixpak's Wayland socket bind, so they always agree.
        WAYLAND_DISPLAY = sloth.envOr "WAYLAND_DISPLAY" "wayland-0";
        XDG_SESSION_TYPE = "wayland";
        # GTK reads an empty GTK_A11Y as an unknown backend; "0" is its unset value.
        GTK_A11Y = sloth.envOr "GTK_A11Y" "0";

        XDG_DATA_DIRS = lib.mkForce (
          lib.makeSearchPath "share" [
            iconTheme
            cursorTheme
            pkgs.shared-mime-info
          ]
        );
        XCURSOR_PATH = lib.mkForce (
          lib.concatStringsSep ":" [
            "${cursorTheme}/share/icons"
            "${cursorTheme}/share/pixmaps"
          ]
        );
      }
      // passHostEnv [
        "LANG"
        "LANGUAGE"
        "LC_ALL"
        "LC_ADDRESS"
        "LC_COLLATE"
        "LC_CTYPE"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MESSAGES"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"

        "NO_AT_BRIDGE"
        "NIXOS_XDG_OPEN_USE_PORTAL"
        "NIXOS_OZONE_WL" # QQ's wrapper adds its Wayland flags only when set
        "XCURSOR_THEME"
        "XCURSOR_SIZE"
        "QT_QPA_PLATFORMTHEME"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION"
      ];
    };
  };
}
