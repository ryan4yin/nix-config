#!/usr/bin/env nu

# Sunshine clipboard bridge (host side)
#
# Reads raw text from stdin and sets it as the clipboard of the compositor that
# is currently streaming via Sunshine, so pasting inside the stream is a plain
# Ctrl+V. Moonlight's built-in "type clipboard text" (Ctrl+Alt+Shift+V) is not
# usable here: Sunshine re-types the payload as Ctrl+Shift+U hex key events,
# which only GTK widgets understand, so browsers and terminals garble it.
#
# The streamed compositor is discovered through the running `sunshine` process
# (its WAYLAND_DISPLAY / XDG_RUNTIME_DIR). This works for both a headless
# greetd-sunshine remote session and a regular desktop session.
#
# Usage (input must be a pipe, not a tty):
#
#   printf 'https://example.com/path?q=1' | nu clipboard.nu
#   wl-paste -n | nu clipboard.nu
#
# Usage from a Moonlight client over SSH (see send-clipboard.nu):
#
#   wl-paste -n | ssh ryan@ai "nu ~/nix-config/modules/nixos/desktop/networking/sunshine/clipboard.nu"

def main [
  --user (-u): string = "" # Sunshine session user (default: SUDO_USER or current user)
  --display (-d): string = "" # Override WAYLAND_DISPLAY (auto-detected from the sunshine process)
  --verify (-v) # Read the clipboard back and fail if it differs from the input
] {
  if (is-terminal --stdin) {
    error make {
      msg: 'no input: pipe text on stdin, e.g. `printf "text" | nu clipboard.nu`'
    }
  }

  let raw = (open --raw /dev/stdin)
  if ($raw | str trim) == '' {
    error make { msg: 'empty input: nothing to copy' }
  }

  let user = (effective-user $user)
  let pid = (streaming-sunshine-pid $user)
  if $pid < 0 {
    error make {
      msg: $"no running `sunshine` process for user `($user)`"
      help: 'start the Sunshine session first (headless: `sudo nu ./remote-session.nu`)'
    }
  }

  let runtime = (proc-env $pid 'XDG_RUNTIME_DIR' $"/run/user/(^id -u $user | str trim)")
  let display = if $display != '' {
    $display
  } else {
    let detected = (proc-env $pid 'WAYLAND_DISPLAY' '')
    if $detected != '' { $detected } else { (single-wayland-display $runtime) }
  }

  let target_env = {
    WAYLAND_DISPLAY: $display
    XDG_RUNTIME_DIR: $runtime
  }

  # wl-copy forks a server that must outlive this process and serve the
  # selection; redirect its stdio so the daemon does not hold our pipes open.
  with-env $target_env {
    $raw | ^wl-copy out> /dev/null err> /dev/null
  }
  if $env.LAST_EXIT_CODE != 0 {
    error make { msg: 'wl-copy failed to set the clipboard' }
  }

  if $verify {
    let pasted = (with-env $target_env { ^wl-paste -n | complete })
    if $pasted.exit_code != 0 or ($pasted.stdout | str trim) != ($raw | str trim) {
      error make { msg: 'verification failed: clipboard content differs from the input' }
    }
  }
}

def effective-user [user: string] {
  if $user != '' { return $user }
  $env.SUDO_USER? | default (whoami)
}

def streaming-sunshine-pid [user: string] {
  let found = (^pgrep -o -u $user -x sunshine | complete)
  if $found.exit_code != 0 { return (-1) }
  ($found.stdout | str trim | into int)
}

def proc-env [pid: int, key: string, fallback: string] {
  let environ = (open --raw $"/proc/($pid)/environ")
  for kv in ($environ | split row "\u{0}") {
    if ($kv | str starts-with $"($key)=") {
      return ($kv | str replace $"($key)=" '')
    }
  }
  $fallback
}

def single-wayland-display [runtime: string] {
  let sockets = (ls $runtime
    | where { |it| ($it.name | path basename) =~ '^wayland-[0-9]+$' }
    | get name)
  if ($sockets | length) == 1 {
    return ($sockets.0 | path basename)
  }
  error make {
    msg: $"cannot determine WAYLAND_DISPLAY under ($runtime)"
    help: $"candidates: (($sockets | path basename | str join ', ')) -- pass --display explicitly"
  }
}
