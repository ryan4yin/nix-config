# nixpak bubblewrap wrapper for hotplug-capable FIDO2 security-key passthrough.
#
# The host udev rules in ../default.nix hard-link FIDO-tagged hidraw nodes into
# fidoDir, which browser-permissions.nix dev-binds into the sandbox, so keys
# plugged in after launch appear there too. Browsers open the devnode named by
# sysfs (/dev/hidrawN), so this wrapper adds one /dev/hidrawN symlink per
# possible hidraw minor; links for non-FIDO HID devices dangle. nixpak has no
# symlink option, hence the wrapper.
{ pkgs, fidoDir }:
let
  inherit (pkgs) lib;
  # HIDRAW_MAX_DEVICES in include/linux/hidraw.h.
  minors = map toString (lib.range 0 63);
  symlinkArgs = lib.concatMapStringsSep " " (
    n: "--symlink ${fidoDir}/hidraw${n} /dev/hidraw${n}"
  ) minors;
in
pkgs.writeShellScriptBin "bwrap" ''
  # Symlinks go right before the app command so they land in the sandbox /dev
  # created by --dev. Helper sandboxes such as the D-Bus proxy pass no "--" and
  # run unchanged.
  args=()
  while [ "$#" -gt 0 ]; do
    if [ "$1" = "--" ]; then
      args+=(${symlinkArgs})
      break
    fi
    args+=("$1")
    shift
  done
  exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" "$@"
''
