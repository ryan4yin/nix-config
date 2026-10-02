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
  # Each terminal attaches to its own session (a bare `tuios` would attach to
  # the most recent one). tuios starts its daemon on demand, so no systemd unit
  # is needed.
  programs.nushell.extraConfig = ''
    # auto start tuios
    if $nu.is-interactive and (not ("TUIOS_SESSION" in $env)) {
      let session = if ("KITTY_WINDOW_ID" in $env) { "kitty" } else { "main" }
      ^tuios attach $session -c
    }
  '';
}
