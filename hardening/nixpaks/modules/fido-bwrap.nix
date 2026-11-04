# Replacement `bwrap` for browsers with browserPermissions.fido2 (Firefox,
# Chromium, Chrome), so they can use FIDO2 security keys.
#
# The problem: browsers find keys by listing /sys/class/hidraw, then open the
# FIDO ones at /dev/hidrawN (e.g. /dev/hidraw6). The sandbox /dev is a private
# tmpfs, so those nodes are missing. The number N is only known once a key is
# plugged in, which may be after the browser starts.
#
# How keys reach the sandbox:
# 1. Host (../default.nix): when a key is plugged in, udev hard-links its FIDO
#    node into /dev/fido-hidraw/ and deletes it on unplug. Non-FIDO interfaces,
#    such as the CanoKey keyboard, are never linked.
# 2. browser-permissions.nix binds /dev/fido-hidraw into the sandbox. It is a
#    shared live directory, so later plug/unplug shows up inside immediately.
# 3. This script creates /dev/hidraw0 ... /dev/hidraw63 in the sandbox as
#    symlinks into /dev/fido-hidraw/. A link works only while a FIDO key with
#    that number is plugged in; the others fail to open with ENOENT.
#
# nixpak has no option for creating symlinks, so this script adds the
# `--symlink` options and then runs the real bwrap.
{ pkgs, fidoDir }:
pkgs.writers.writePython3Bin "bwrap"
  {
    # Interpolated store paths exceed the default line length.
    flakeIgnore = [ "E501" ];
  }
  ''
    import os
    import sys

    REAL_BWRAP = "${pkgs.bubblewrap}/bin/bwrap"
    FIDO_DIR = "${fidoDir}"
    # The kernel allows at most 64 hidraw devices (HIDRAW_MAX_DEVICES).
    HIDRAW_COUNT = 64

    args = sys.argv[1:]

    # nixpak runs: bwrap <sandbox options> -- <browser command>
    # Insert the symlinks just before "--": by then nixpak's "--dev /dev" has
    # created the sandbox /dev they live in. nixpak's D-Bus proxy sandbox runs
    # bwrap without "--" and stays unchanged.
    if "--" in args:
        symlinks = []
        for n in range(HIDRAW_COUNT):
            # e.g. --symlink /dev/fido-hidraw/hidraw6 /dev/hidraw6
            symlinks += ["--symlink", f"{FIDO_DIR}/hidraw{n}", f"/dev/hidraw{n}"]
        separator = args.index("--")
        args[separator:separator] = symlinks

    os.execv(REAL_BWRAP, [REAL_BWRAP, *args])
  ''
