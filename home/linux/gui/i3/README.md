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

## Input-level control, not CDP

The point of this environment is to look like a real user device, so the agent drives the browser
the same way a person would: real X11/AT-SPI input (`click`, `type_text`, `press_key`, screenshot,
accessibility tree). It does **not** use cua-driver's CDP-backed `browser_*` tools, because
attaching to the existing profile:

- needs a launch grant (`--grant existing-profile`, or unrestricted mode), and
- turns on a **persistent, page-detectable** remote-debugging endpoint, and
- can read data that never renders (cookies, storage) rather than only what is on screen.

So `cua-driver serve` is started with **no** launch grants here, and no `--remote-debugging-port` is
passed to the browsers (see `browserFlags`). Keep it that way: adding either re-introduces the CDP
surface this design avoids.

No automation switches are passed (`--enable-automation`,
`--disable-blink-features=AutomationControlled`, `--remote-debugging-port`): nothing here drives the
browser over CDP, so `navigator.webdriver` is already false. The one flag with a realism cost is
`--force-renderer-accessibility` — few real users force a11y on — but it is required for the AT-SPI
tree the agent reads, so it stays.

## How it is wired

- `home/linux/gui/i3/default.nix` defines the option `modules.desktop.computerUse` and the user
  services: `xvfb` → `i3` → (`x11vnc`, `autocutsel-primary` / `autocutsel-clipboard`,
  `cua-driver serve`).
- `modules/nixos/desktop/computer-use.nix` provides the system side (`linger`, AT-SPI, fonts, Mesa,
  Clash Verge proxy, proxy-region timezone).
- the generated `computer-use-init` script (exec'd by i3) publishes `DISPLAY`/`XDG_SESSION_TYPE` to
  the systemd user manager, clears any stale `WAYLAND_DISPLAY`, and enables the AT-SPI bridge via a
  gsettings key.
- Drivers live in `overlays/cua-driver.nix` and `overlays/computer-use-linux.nix`.
- Host wiring: `home/hosts/linux/idols-ruby.nix`, `home/hosts/linux/idols-kana.nix`,
  `hosts/idols-ruby/computer-use.nix`.

## The i3 config

The generated config is intentionally minimal:

- `font pango:monospace 10`
- `default_border normal` — keeps title bars, so the client area is slightly smaller than the
  screen. That matches a real desktop and avoids a full-screen-sized viewport.
- `exec --no-startup-id .../computer-use-init` — one-time session setup, see above.

There are no keybindings, bars or autostarted apps: agents drive the session through the drivers,
not the keyboard.

## Manual access over VNC

`x11vnc` binds `127.0.0.1:5900` with no password, so manual inspection goes through an SSH tunnel
rather than exposing the port. Remmina's VNC profile has an **SSH Tunnel** tab for this; the manual
equivalent is:

```bash
ssh -L 5900:127.0.0.1:5900 <host>
# then point the VNC client at 127.0.0.1:5900
```

## Clipboard

Xvfb has no clipboard of its own and an X11 selection lives only as long as the application that
owns it, so without help a VNC client's clipboard sync is unreliable. Two `autocutsel` instances
mirror the `PRIMARY` and `CLIPBOARD` selections, which makes copy/paste work both inside the session
and between it and the VNC client.
