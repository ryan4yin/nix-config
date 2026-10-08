{
  config,
  pkgs,
  tuios,
  ...
}:
let
  # nixpkgs lags behind upstream; use the flake input.
  tuiosPkg = tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios;

  # tuios watches config.toml and its settings page writes it back, so link the
  # checked-in file out-of-store instead of into the store.
  configDir = "${config.home.homeDirectory}/nix-config/home/base/tui/tuios";
in
{
  home.packages = [ tuiosPkg ];

  xdg.configFile."tuios/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${configDir}/config.toml";

  # auto-start tuios in interactive shells, except when already inside tuios.
  # Two sessions, split by purpose: `work` for the ~/work tree, `personal` for
  # everything else (a host with no ~/work gets `personal` everywhere). The
  # session follows the directory the shell starts in, not the terminal
  # emulator, so ghostty and kitty land in the same session. A bare `tuios`
  # would attach to the most recent session instead of this one, and `-c`
  # creates the session the first time. tuios starts its daemon on demand, so no
  # systemd unit is needed.
  programs.nushell.extraConfig = ''
    # auto start tuios
    if $nu.is-interactive and (not ("TUIOS_SESSION" in $env)) {
      let work_root = ($nu.home-dir | path join "work")
      let session = if $env.PWD == $work_root or ($env.PWD | str starts-with $"($work_root)/") {
        "work"
      } else {
        "personal"
      }
      ^tuios attach $session -c
    }
  '';
}
