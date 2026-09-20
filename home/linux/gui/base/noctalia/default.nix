{
  config,
  lib,
  pkgs,
  wallpapers,
  ...
}:

{
  # Use the upstream Home Manager module (shipped by home-manager itself) for
  # the package. The config file is not deployed through `programs.noctalia.settings`:
  # that writes a store symlink, so every edit needs a home-manager switch.
  # https://docs.noctalia.dev/noctalia/getting-started/nixos/#home-manager
  programs.noctalia.enable = true;
  # Deploy the baseline as an out-of-store symlink in the config layer. Noctalia
  # never rewrites files under ~/.config/noctalia/, so manual edits hot-reload
  # without a switch, while Settings UI changes stay in the state layer
  # (~/.local/state/noctalia/settings.toml), which loads last and wins - keeping
  # volatile runtime data (wallpaper rotation, widget geometry) out of the repo.
  # Host-specific tweaks are separate config-layer files (~/.config/noctalia/host-<host>.toml).
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/linux/gui/base/noctalia/config/config.toml";

  # Noctalia v5 is started by niri's spawn-at-startup (see the niri conf), so
  # app2unit is still used to launch desktop entries as systemd user units.
  home.packages = [
    pkgs.app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
  ]
  ++ (lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    pkgs.gpu-screen-recorder # recoding screen
  ]);

  home.file."Pictures/Wallpapers".source = wallpapers;
}
