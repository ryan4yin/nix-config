#!/usr/bin/env nu
#
# Prelaunch fix for Wuthering Waves, run by scripts/umu-install.nu (and the
# generated ~/Games/wuthering-waves/run) with the game's WINEPREFIX already set.
#
# The newer launcher is WebView2/.NET; under Wine its WPF window stays
# transparent, so it renders invisible. The fix -- the same one Lutris'
# "Wuthering Waves (Official Launcher)" script applies -- is an equal-length
# rename of the AllowsTransparency property in launcher_main.dll. It is redone
# before every launch because a launcher self-update overwrites the file.

def game-dir [] {
  $env.WINEPREFIX | path join "drive_c/Program Files/Wuthering Waves"
}

# The launcher unpacks itself into a version directory named X.Y.Z.W.
def version-dir [] {
  let found = (^find (game-dir) -maxdepth 1 -type d -name '[0-9]*.[0-9]*.[0-9]*.[0-9]*' | complete)
  let dirs = ($found.stdout | ^sort -V | lines)
  if ($dirs | is-empty) {
    error make { msg: $"launcher not installed under '(game-dir)' -- run: just umu-install wuthering-waves <setup.exe> <launcher>" }
  }
  $dirs | last
}

# Equal-length byte rename, idempotent. bbe interprets the \xNN escapes itself,
# so the expression must stay a single-quoted (raw) string.
def main [] {
  let dll = (version-dir | path join "launcher_main.dll")
  if (^grep -a -q $"\u{12}AllowsTransparency" $dll | complete).exit_code != 0 {
    print "launcher_main.dll is already patched"
    return
  }
  cp $dll $"($dll).bak"
  ^bbe -e 's/\x12AllowsTransparency/\x09IsEnabled\x1bA\x00\x03AAAAA/' $"($dll).bak" o> $dll
  print $"patched ($dll)"
}
