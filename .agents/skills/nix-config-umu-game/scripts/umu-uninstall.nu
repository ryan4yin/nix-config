#!/usr/bin/env nu
#
# Remove a game installed by umu-install.nu: drop the desktop entry it wrote,
# then, after confirmation, delete ~/Gaming/Games/<name> (prefix and game
# files). It runs from this repo because anything under ~/Gaming is writable by
# the games.
#
#   nu .agents/skills/nix-config-umu-game/scripts/umu-uninstall.nu wuthering-waves

use common.nu *

def main [name: string] {
  check-name $name
  reject-symlinked-roots
  let dir = ((games-dir) | path join $name)
  reject-symlink $dir "game directory"

  # Remove the entry only if umu-install.nu wrote it for this game.
  let entry = ($nu.home-dir | path join ".local/share/applications" $"($name).desktop")
  let exec = (open --raw ($env.FILE_PWD | path join "templates/launcher.desktop.tpl")
    | lines | where ($it | str starts-with "Exec=") | first
    | str replace "@RUN@" (sandbox-path ($dir | path join "run")))
  if not ($entry | path exists) {
    print "no desktop entry"
  } else if $exec in (open --raw $entry | lines) {
    rm --force $entry
    print "desktop entry removed"
  } else {
    print $"kept ($entry): its Exec is not ($exec)"
  }

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
