# i3 — headless computer-use session

This module provides the headless X11 session used by the computer-use VMs (`idols-ruby`,
`idols-kana`). It is **not** a normal desktop configuration and is not meant to be used
interactively by a person.

## Purpose

Give a computer-use agent a virtual 1920x1080 X display it can observe and control: screenshots,
window discovery/activation, synthetic input, and the AT-SPI accessibility tree. The agent itself
runs elsewhere and connects over MCP; this module is only the "computer" side.

The session is built on Xvfb plus i3 because the drivers support native X11 at their highest tier
(cua-driver "Linux X11 — Supported"; computer-use-linux has an i3 backend). cua-driver's Sway lane
is XWayland/X11-based, so a native X11 session is simpler and better supported than Sway/Wayland.

## How it is wired

- `home/linux/gui/i3/default.nix` defines the option `modules.desktop.computerUse` and the user
  services: `xvfb` → `i3` → (`x11vnc`, `cua-driver serve`).
- `modules/nixos/desktop/computer-use.nix` provides the system side (`linger`, AT-SPI, fonts, Mesa,
  Clash Verge proxy, proxy-region timezone).
- the generated `computer-use-init` script (exec'd by i3) publishes `DISPLAY`/`XDG_SESSION_TYPE` to
  the systemd user manager, clears any stale `WAYLAND_DISPLAY`, and enables the AT-SPI bridge via a
  gsettings key.
- Drivers live in `overlays/cua-driver.nix` and `overlays/computer-use-linux.nix`.
- Host wiring: `home/hosts/linux/idols-ruby.nix`, `home/hosts/linux/idols-kana.nix`.

## The i3 config

The generated config is intentionally minimal:

- `font pango:monospace 10`
- `default_border normal` — keeps title bars, so the client area is slightly smaller than the
  screen. That matches a real desktop and avoids a full-screen-sized viewport.
- `exec --no-startup-id .../computer-use-init` — one-time session setup, see above.

There are no keybindings, bars or autostarted apps: agents drive the session through the drivers,
not the keyboard. Manual inspection is done over VNC (`x11vnc`, bound to `127.0.0.1`; reach it
through an SSH tunnel).
