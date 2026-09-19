{
  lib,
  pkgs,
  wallpapers,
  ...
}:

{
  # Use the upstream Home Manager module (shipped by home-manager itself): it
  # installs pkgs.noctalia, validates the TOML at build time via `checkConfig`,
  # and handles custom palettes. Runtime changes made in the Settings UI keep
  # working: they go to ~/.local/state/noctalia/settings.toml, which loads after
  # this file and wins.
  # https://docs.noctalia.dev/noctalia/getting-started/nixos/#home-manager
  programs.noctalia = {
    enable = true;
    settings = ./config/config.toml;
  };

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
