# nixpak bubblewrap wrapper that adds narrow FIDO2 security-key passthrough.
#
# Chromium and Firefox enumerate FIDO2 tokens through udev/sysfs and open the
# hidraw node directly. nixpak's bwrap arguments are fixed at build time and
# hidraw numbering is dynamic, so this wrapper discovers the FIDO-tagged nodes
# at launch and injects only those after --dev /dev. Only interfaces whose
# report descriptor declares the FIDO usage page are bound: the CanoKey's KBD
# interface and CCID stay hidden. /sys and /run/udev are added read-only only
# while a token is present.
{ pkgs }:
pkgs.writeShellScriptBin "bwrap" ''
  set -eu

  real_bwrap=${pkgs.bubblewrap}/bin/bwrap
  udevadm=${pkgs.systemd}/bin/udevadm
  grep=${pkgs.gnugrep}/bin/grep

  # Only the application sandbox has --dev /dev; xdg-dbus-proxy and other
  # helper invocations pass through unchanged.
  has_dev=0
  for arg in "$@"; do
    if [ "$arg" = "--" ]; then
      break
    fi
    if [ "$arg" = "--dev" ]; then
      has_dev=1
      break
    fi
  done
  if [ "$has_dev" -eq 0 ]; then
    exec "$real_bwrap" "$@"
  fi

  # systemd's fido_id builtin tags hidraw devices whose report descriptor
  # declares the FIDO usage page. CanoKey exposes a separate HID(KBD) interface
  # which is not tagged and is deliberately kept out of the browser.
  nodes=()
  for hidraw in /sys/class/hidraw/hidraw*; do
    if [ ! -e "$hidraw" ]; then
      continue
    fi
    node="/dev/''${hidraw##*/}"
    if [ ! -e "$node" ]; then
      continue
    fi
    if "$udevadm" info -q property -n "$node" 2>/dev/null | "$grep" -qx 'ID_FIDO_TOKEN=1'; then
      nodes+=("$node")
    fi
  done

  args=()
  while [ "$#" -gt 0 ]; do
    if [ "$1" = "--" ]; then
      args+=("$@")
      break
    fi
    if [ "$1" = "--dev" ] && [ "''${2:-}" = "/dev" ]; then
      args+=(--dev /dev)
      shift 2
      if [ "''${#nodes[@]}" -gt 0 ]; then
        args+=(--ro-bind-try /sys /sys --ro-bind-try /run/udev /run/udev)
        for node in "''${nodes[@]}"; do
          args+=(--dev-bind-try "$node" "$node")
        done
      fi
      continue
    fi
    args+=("$1")
    shift
  done
  exec "$real_bwrap" "''${args[@]}"
''
