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
  # `work` for the ~/work tree, `personal` for everything else (a host with no
  # ~/work gets `personal` everywhere).
  programs.nushell.extraConfig = ''
    # TUIOS keeps TERM=xterm-256color for terminfo compatibility, even though
    # this host's only terminal emulators (kitty and Ghostty) both speak the
    # Kitty graphics protocol and TUIOS forwards it. Force the guest TERM to
    # xterm-kitty so graphics-aware apps do not disable themselves; its
    # terminfo entry comes with kitty.
    if ("TUIOS_ENV" in $env) {
      $env.TERM = "xterm-kitty"
    }

    if $nu.is-interactive and (not ("TUIOS_SESSION" in $env)) {
      # Exit 3 means the daemon is stopped; stdout still lists saved sessions.
      let listing = (^tuios ls --json | complete)
      if $listing.exit_code not-in [0 3] {
        error make {msg: $"tuios ls failed: ($listing.stderr)"}
      }
      let sessions = ($listing.stdout | from json | get name)
      let work_root = ($nu.home-dir | path join "work")
      if $env.PWD == $work_root or ($env.PWD | str starts-with $"($work_root)/") {
        if "work" not-in $sessions {
          ^tuios new work --detach --cwd $work_root
        }
        ^tuios attach work
      } else {
        if "personal" not-in $sessions {
          ^tuios new personal --detach --cwd $nu.home-dir
        }
        ^tuios attach personal
      }
    }
  '';
}
