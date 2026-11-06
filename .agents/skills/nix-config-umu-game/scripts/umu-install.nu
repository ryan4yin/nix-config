#!/usr/bin/env nu
#
# Install a Windows game launcher into its own umu-launcher Wine prefix, and
# generate launch/exec/desktop helpers for it.
#
# umu-launcher is the Proton backend Lutris/Heroic use: it creates and runs a
# detached Wine prefix without Steam, and a GAMEID from the umu database pulls
# in that game's protonfixes (fonts, env quirks, save location, ...). This
# installer is fully generic -- it knows no game names. Every per-game detail
# lives under ~/Gaming/Games/<name>/ (~/Games/<name>/ inside the sandbox):
#
#   prefix      the Wine prefix (WINEPREFIX)
#   prelaunch   optional executable, run before every launch
#   conf        optional shell file overriding the generated defaults
#   run         generated launcher
#   exec        generated helper: run any exe/wine tool in the prefix
#   <name>.desktop  generated desktop entry
#
# Games only run in the umu sandbox (hardening/nixpaks/umu.nix), which mounts
# ~/Gaming over $HOME. The installer, prelaunch, run and exec all execute inside
# it via `umu-sandbox`, so the paths written into run, exec and the desktop
# entry are sandbox paths; this script, on the host, only writes files.
# umu-uninstall.nu removes a game.
#
# ~/Gaming/Games/global.conf, if present, is sourced by every run script before
# the game's own conf; both may set ENABLE_GAMEMODE, ENABLE_GAMESCOPE,
# GAMESCOPE_ARGS, ENABLE_LOG, PROTONPATH, GAMEID, LAUNCHER, ...
#
# PROTONPATH is resolved from $PROTONPATH, then $UMU_PROTONPATH (exported by
# modules/nixos/desktop/gaming.nix from pkgs.dwproton-bin), then Steam's
# per-user compatibilitytools.d in the sandbox home. It must be visible in the
# sandbox: the Nix store or ~/Gaming.
#
#   nu .agents/skills/nix-config-umu-game/scripts/umu-install.nu wuthering-waves \
#     ~/Downloads/WutheringWaves_setup_3.5.0.exe \
#     "drive_c/Program Files/Wuthering Waves/launcher.exe" \
#     umu-3513350
#
# Extra arguments after [gameid] are passed to the installer, e.g. "/S" or
# "/quiet" for a silent install. A <setup.exe> of "-" skips the installer and
# only rewrites the launchers.

use common.nu *

# First candidate that actually contains a proton script.
def resolve-protonpath [] {
  let explicit = ($env.PROTONPATH? | default "")
  if (not ($explicit | is-empty)) and (($explicit | path join "proton") | path exists) {
    return $explicit
  }
  let umu = ($env.UMU_PROTONPATH? | default "")
  if (not ($umu | is-empty)) and (($umu | path join "proton") | path exists) {
    return $umu
  }
  let steam = ((gaming-dir) | path join ".local/share/Steam/compatibilitytools.d/dwproton")
  if (($steam | path join "proton") | path exists) {
    return $steam
  }
  null
}

# "wuthering-waves" -> "Wuthering Waves"
def display-name [name: string] {
  $name | split row "-" | each { |w| $w | str capitalize } | str join " "
}

def usage [] {
  print "Usage: .agents/skills/nix-config-umu-game/scripts/umu-install.nu <name> <setup.exe> <launcher> [gameid] [setup-args...]"
  print ""
  print "  <name>       directory under ~/Gaming/Games (e.g. wuthering-waves)"
  print "  <setup.exe>  installer to run through umu (copied into the game directory"
  print "               unless the sandbox sees it), or - to skip it"
  print "  <launcher>   launcher to run later, relative to the prefix"
  print "  [gameid]     umu database id for protonfixes (default umu-default)"
  print "  [setup-args] extra args for setup.exe, e.g. /S or /quiet"
  print ""
  print "Writes ~/Gaming/Games/<name>/{run,exec,<name>.desktop}; launch with"
  print "umu-sandbox ~/Games/<name>/run (a sandbox path). A per-game fix goes in"
  print "prelaunch; overrides go in conf or ~/Gaming/Games/global.conf. PROTONPATH"
  print "comes from $PROTONPATH or $UMU_PROTONPATH."
}

# Quote substituted shell values as data, including literal apostrophes.
def shell-quote [value: string] {
  "'" + ($value | str replace --all "'" "'\\''") + "'"
}

def render-template [name: string, values: record] {
  let template = ($env.FILE_PWD | path join "templates" $name)
  open --raw $template | str replace --all --regex '@([A-Z_]+)@' { |key|
    $values | get $key
  }
}

def write-run [dir: string, launcher: string] {
  let values = {
    WINEPREFIX: (shell-quote $env.WINEPREFIX)
    PROTONPATH: (shell-quote $env.PROTONPATH)
    GAMEID: (shell-quote $env.GAMEID)
    LAUNCHER: (shell-quote $launcher)
  }
  for file in [run exec] {
    let target = ($dir | path join $file)
    reject-symlink $target $file
    render-template $"($file).sh.tpl" $values | save --force $target
    ^chmod +x $target
  }
}

def write-integration [name: string, dir: string] {
  let apps = ($nu.home-dir | path join ".local/share/applications")
  let entry = ($apps | path join $"($name).desktop")
  let copy = ($dir | path join $"($name).desktop")
  let desktop = (render-template "launcher.desktop.tpl" {
    DISPLAY_NAME: (display-name $name)
    RUN: (sandbox-path ($dir | path join "run"))
  })
  mkdir $apps
  reject-symlink $copy "desktop entry copy"
  $desktop | save --force $copy
  $desktop | save --force $entry
}

# Run a command in the umu sandbox with the game's environment. Start from the
# host home: inside, that path is the sandbox home, so the working directory
# exists on both sides.
def in-sandbox [...command: string] {
  cd $nu.home-dir
  (^umu-sandbox env
    $"WINEPREFIX=($env.WINEPREFIX)"
    $"PROTONPATH=($env.PROTONPATH)"
    $"GAMEID=($env.GAMEID)"
    ...$command)
}

def main [...args: string] {
  if ($args | length) < 3 {
    usage
    exit 1
  }
  let name = ($args | get 0)
  check-name $name
  let setup = ($args | get 1)
  let launcher = ($args | get 2)
  let gameid = (if ($args | length) >= 4 { $args | get 3 } else { "umu-default" })
  let setupArgs = (if ($args | length) >= 5 { $args | skip 4 } else { [] })
  reject-symlinked-roots
  let dir = ((games-dir) | path join $name)
  let prefix = ($dir | path join "prefix")
  reject-symlink $dir "game directory"
  reject-symlink $prefix "Wine prefix"
  if $setup != "-" and not ($setup | path exists) {
    print --stderr $"error: installer not found: ($setup)"
    exit 2
  }

  let protonpath = (resolve-protonpath)
  if $protonpath == null {
    print --stderr "error: no Proton found. Set PROTONPATH or UMU_PROTONPATH, or rebuild NixOS so modules/nixos/desktop/gaming.nix exports UMU_PROTONPATH."
    exit 1
  }
  let visibleProton = (sandbox-path $protonpath)
  if $visibleProton == null {
    print --stderr $"error: the umu sandbox cannot see PROTONPATH ($protonpath); use a Nix store path or one under ~/Gaming"
    exit 2
  }
  $env.PROTONPATH = $visibleProton

  mkdir $dir
  $env.WINEPREFIX = (sandbox-path $prefix)
  $env.GAMEID = $gameid

  if $setup != "-" {
    # The sandbox sees only ~/Gaming and the store, so bring the installer in.
    let installer = (if ((sandbox-path $setup) != null) {
      sandbox-path $setup
    } else {
      let target = ($dir | path join ($setup | path basename))
      reject-symlink $target "installer copy"
      cp $setup $target
      sandbox-path $target
    })

    print $"installing '($name)' into ($prefix)"
    print $"  PROTONPATH = ($env.PROTONPATH)"
    print $"  GAMEID     = ($env.GAMEID)"
    print "run the installer, then exit it (do not start the game)."

    let inst = (in-sandbox umu-run $installer ...$setupArgs | complete)
    if $inst.exit_code != 0 {
      print --stderr $"installer exited ($inst.exit_code); writing the launchers anyway"
    }

    let prelaunch = ($dir | path join "prelaunch")
    if ($prelaunch | path exists) {
      print $"running prelaunch in the sandbox: ($prelaunch)"
      in-sandbox (sandbox-path $prelaunch)
    }
  }

  write-run $dir $launcher
  write-integration $name $dir
  # Older versions generated an uninstall script here for the host to run;
  # a game could rewrite it. umu-uninstall.nu replaces it.
  let uninstall = ($dir | path join "uninstall")
  if ((try { $uninstall | path type } catch { "missing" }) != "missing") {
    rm --force $uninstall
  }
  print $"done. launch with: umu-sandbox (sandbox-path ($dir | path join run))"
}
