#!/usr/bin/env nu

# Sunshine clipboard bridge (client side)
#
# Sends the local client clipboard to the Sunshine host and writes it into the
# clipboard of the streamed session, so pasting inside the stream is a plain
# Ctrl+V. Prefer this over Moonlight's Ctrl+Alt+Shift+V, which "types" the text
# via unicode-hex key events and garbles it in non-GTK apps (e.g. browsers).
#
# Requires:
#   - wl-clipboard (wl-paste) on this machine, inside a Wayland session
#   - key-based SSH access to the host (the pipe needs a non-interactive session)
#   - the host-side `clipboard.nu` reachable at --remote (default assumes the
#     repo is cloned at ~/nix-config on the host)
#
# Usage:
#   nu send-clipboard.nu ryan@ai
#   nu send-clipboard.nu ryan@ai --remote /abs/path/to/clipboard.nu

def main [
  host: string = "" # SSH target of the Sunshine host, e.g. ryan@ai
  --remote: string = "~/nix-config/modules/nixos/desktop/networking/sunshine/clipboard.nu"
] {
  if $host == '' {
    error make {
      msg: 'missing SSH target'
      help: 'usage: nu send-clipboard.nu <ssh-target>, e.g. `nu send-clipboard.nu ryan@ai`'
    }
  }

  let picked = (^wl-paste -n | complete)
  if $picked.exit_code != 0 {
    error make { msg: $"wl-paste failed: ($picked.stderr | str trim)" }
  }
  if ($picked.stdout | str trim) == '' {
    error make { msg: 'client clipboard is empty: copy some text first' }
  }

  $picked.stdout | ^ssh -o BatchMode=yes $host $"nu ($remote)"
  if $env.LAST_EXIT_CODE != 0 {
    error make {
      msg: $"could not write clipboard to ($host)"
      help: 'ensure key-based SSH works (`ssh -o BatchMode=yes <target> true`) and the remote script path is correct'
    }
  }
}
