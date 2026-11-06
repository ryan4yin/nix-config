#!/usr/bin/env nu
#
# Run a Windows tool against a Steam game's Proton prefix, inside the game
# sandbox. Steam's prefixes live under ~/Gaming, which the host never executes,
# so every command goes through umu-sandbox; this replaces protontricks, whose
# host-side runs would load game-writable DLLs with your own privileges.
#
#   nu scripts/steam-fix.nu 1794680 winecfg
#   nu scripts/steam-fix.nu 1794680 wine regedit
#   nu scripts/steam-fix.nu 1794680 wine reg add 'HKCU\Software\...' /v X /d Y
#
# The prefix is steamapps/compatdata/<appid>/pfx (ls that directory for the
# AppIDs of games that have run at least once). The Proton build is the one
# NixOS exports as $UMU_PROTONPATH.
def main [appid: string, ...command: string] {
  if not ($appid =~ '^[0-9]+$') {
    print --stderr "error: appid must be a number, e.g. 1794680 (see steamapps/compatdata)"
    exit 2
  }
  if ($command | is-empty) {
    print "usage: steam-fix <appid> <command...>   e.g. steam-fix 1794680 winecfg"
    exit 1
  }
  let proton = ($env.UMU_PROTONPATH? | default "")
  if ($proton | is-empty) {
    print --stderr "error: UMU_PROTONPATH is not set; it comes from modules/nixos/desktop/gaming.nix"
    exit 1
  }
  let gaming = ($nu.home-dir | path join "Gaming")
  let data = ($gaming | path join ".local/share/Steam/steamapps/compatdata" $appid)
  if not ($data | path exists) {
    print --stderr $"error: no prefix for ($appid); ($data) does not exist -- run the game once first"
    exit 1
  }
  # ~/Gaming is the sandbox $HOME, so drop that component for sandbox paths.
  let sandboxData = ($data | str replace $gaming $nu.home-dir)
  let args = (
    [
      "env"
      $"STEAM_COMPAT_CLIENT_INSTALL_PATH=($nu.home-dir)/.local/share/Steam"
      $"STEAM_COMPAT_DATA_PATH=($sandboxData)"
      $"WINEPREFIX=($sandboxData)/pfx"
      $"($proton)/proton"
      "run"
    ]
    | append $command
  )
  ^umu-sandbox ...$args
}
