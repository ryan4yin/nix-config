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
  # cursor & icon's theme should be the same as the host's one.
  cursorTheme = pkgs.bibata-cursors;
  iconTheme = pkgs.papirus-icon-theme;
in
{
  config = {
    dbus.policies = {
      "${config.flatpak.appId}" = "own";
      # we add other policies in ./common.nix
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
      bind.rw = [
        [
          (envSuffix "HOME" "/.var/app/${config.flatpak.appId}/cache")
          sloth.xdgCacheHome
        ]
        (sloth.concat' sloth.xdgCacheHome "/fontconfig")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")

        (sloth.concat [
          (sloth.env "XDG_RUNTIME_DIR")
          "/"
          (sloth.envOr "WAYLAND_DISPLAY" "no")
        ])

        (envSuffix "XDG_RUNTIME_DIR" "/at-spi/bus")
        (envSuffix "XDG_RUNTIME_DIR" "/gvfsd")
        (envSuffix "XDG_RUNTIME_DIR" "/pulse")

        "/run/dbus"
      ];
      bind.ro = [
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

      env = {
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
      };
    };
  };
}
