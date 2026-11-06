#!/usr/bin/env nu
#
# Remove a game installed by umu-install.nu: drop its desktop entry, then,
# after confirmation, delete ~/Gaming/Games/<name> (prefix and game files). It
# runs from this repo because anything under ~/Gaming is writable by the games.
#
#   nu .agents/skills/nix-config-umu-game/scripts/umu-uninstall.nu wuthering-waves

use common.nu *

def main [name: string] {
  check-name $name
  reject-symlinked-roots
  let dir = ((games-dir) | path join $name)
  reject-symlink $dir "game directory"

  let entry = ($nu.home-dir | path join ".local/share/applications" $"($name).desktop")
  rm --force $entry
  print "desktop entry removed"

  if not ($dir | path exists) {
    print $"nothing to delete at ($dir)"
    return
  }
  print --no-newline $"Delete ($dir) and all its files? [y/N] "
  # nu's `input` ignores piped stdin; head reads it either way.
  let answer = (^head -n 1 | str trim)
  if $answer in [y Y] {
    rm --recursive --force $dir
    print $"removed ($dir)"
  } else {
    print $"kept ($dir)"
  }
}
