---
name: Nix Config Desktop
description:
  Use when changing the Niri/Noctalia desktop, the Wayland session, input method (fcitx5), theming,
  fonts, or desktop autostart in this repo. Covers which layer owns a setting, live reload vs a
  rebuild, and how to verify the result on screen.
---

# Changing the desktop

The desktop is a Niri + Noctalia Wayland session. Most of it is deployed as **out-of-store
symlinks**, so a config edit takes effect live, rolls back with git, and needs no rebuild. Rebuild
only the store layer.

The current desktop is the `ai-niri` nixosConfiguration (hostName `ai`): `home/linux/gui/**` plus
`hosts/idols-ai/niri-hardware.kdl` for this machine's outputs.

## Core rules

1. **Edit the config layer, not the store.** Runtime-tweakable things (Niri KDL, Noctalia TOML) live
   in files symlinked out of store. Editing them applies immediately; a rebuild is wasted time, and
   it hides the change behind a generation.
2. **Validate before you reload.** `niri validate` and `noctalia config validate` catch a typo
   cheaply. A config that fails to parse does not crash the session — Niri keeps the last working
   state and shows a "Failed to parse the config file" notification — but the change silently does
   not apply, which is easy to misread as "my edit did nothing".
3. **Look at it.** Anything that renders (bar, OSD, notifications, wallpaper, corners) is not done
   until a screenshot shows it correct. A setting that parses is not a setting that looks right.
4. **One concern per commit.** The config layer is testable in place; keep each edit small enough to
   revert by itself.
5. **`just niri` is the user's to run.** It activates the machine you are on through
   `nixos-rebuild --sudo` and blocks on a password prompt.

## 1. Pick the layer

| Change                                        | Where it lives                                                | Applies                                                    |
| --------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------------- |
| Niri compositor (binds, layout, window rules) | `home/linux/gui/niri/conf/*.kdl`                              | live                                                       |
| Niri per-host hardware (outputs, variables)   | `hosts/<host>/niri-hardware.kdl`                              | live                                                       |
| Noctalia shell baseline                       | `home/linux/gui/base/noctalia/config/config.toml`             | live                                                       |
| Noctalia host override                        | `home/hosts/linux/<host>/noctalia.toml`                       | as a file, live; store path (`source =`) needs `just niri` |
| Noctalia value set through the Settings UI    | `~/.local/state/noctalia/settings.toml`                       | live, and wins over the baseline                           |
| fcitx5 profile / mozc dictionary              | `home/linux/gui/base/fcitx5/`                                 | store: needs `just niri`                                   |
| Theme (catppuccin), fonts                     | `home/base/core/theme.nix`, `modules/nixos/desktop/fonts.nix` | store: needs `just niri`                                   |
| Session, portal and systemd wiring            | `modules/nixos/desktop/**`                                    | store: needs `just niri`                                   |

Noctalia's merge order, `[include]`, and profiles are documented in
[home/linux/gui/base/README.md](../../../home/linux/gui/base/README.md); read that instead of
restating it here.

## 2. Edit and validate

Both config layers are watched and hot-reload, so the validators are the first thing to run:

```bash
niri validate   # parses the live config and its whole include graph
noctalia config validate ./home/linux/gui/base/noctalia/config/config.toml   # this file only
noctalia config validate   # the merged config, as the running shell loads it
```

Validate the **live** Niri config, not the repo copy: `config.kdl` includes `./niri-hardware.kdl`,
which only the host module puts in `~/.config/niri/`, so `niri validate -c <repo path>` fails on the
missing include.

Confirm the layer is really live before trusting a hot reload:

```bash
readlink -f ~/.config/niri/config.kdl        # must end in ~/nix-config/...
readlink -f ~/.config/noctalia/config.toml
```

`~/.config/...` points at a store path that is itself a symlink back into the repo. If it resolves
to a plain store copy instead, the file is not live and the change needs `just niri`.

If an edit does not show up:

- `niri msg action load-config-file` forces a Niri reload.
- `noctalia config export` prints what actually won (`noctalia config export full` adds the built-in
  defaults); diff that against what you wrote.
- `~/.local/state/noctalia/settings.toml` overrides the baseline. A value saved through the Settings
  UI - or left over from an experiment - silently beats `config.toml`.

## 3. Verify on screen

Text checks cannot see the desktop. Take a screenshot and look at it:

```bash
niri msg action screenshot-screen   # focused output, saved to ~/Pictures/Screenshots/ (no UI)
niri msg action screenshot-window   # focused window
```

Then open the newest PNG. The agent can `read` it (images are shown to the model), and
`browser.preview` shows it to the user. There is no grim/slurp/satty here: Niri and Noctalia own the
capture path - `noctalia msg screenshot-fullscreen`, `noctalia msg screenshot-region`, and the
`Print` / `Ctrl+Print` / `Alt+Print` binds.

Capture the frame that proves the change: the bar and OSD for a shell or widget edit, window borders
and corner radius for a layout rule, the specific app for an input-method edit.

Checks a screenshot cannot cover:

- `systemctl --user --failed` and `journalctl --user -b -p err` for a crashed shell or portal unit.
- `niri msg outputs` for mode, scale and transform; `niri msg workspaces` and `niri msg windows` for
  the layout.
- `fcitx5-remote -n` for the active input method, or type into a scratch window.

## 4. Land it

- Config layer: the edit is already live, and `~/.config/...` symlinks into `~/nix-config/...`, so
  the repo file is the source of truth. Commit it; there is no rebuild and no generation.
- Store layer (packages, fonts, theme, systemd units, fcitx5 profile): the user runs `just niri`.
  Confirm the session still comes up, then verify on screen as in step 3.
- New desktop host: add its `niri-hardware.kdl` and wire it in `home/hosts/linux/<host>.nix`, the
  way `idols-ai` and `12kingdoms-shoukei` do.

## 5. Roll back

- Config layer: `git checkout -- <file>` for an uncommitted experiment, or `git revert` for a
  commit, then let it hot-reload. There is no generation to pick.
- Store layer: `just history` lists system generations; boot the previous one.
- If the session will not start at all, log in on a TTY and fix the file. Niri's recovery only
  covers a bad reload, not a broken startup.

## 6. Commands that need care

- **Change the running system**: `just niri` (sudo, user-run) for anything in the store layer.
- **Interrupt the live session**: `niri msg action quit`, `niri msg action power-off-monitors`,
  `noctalia msg dpms-off`, and `noctalia msg lock` act on the desktop the user is looking at - do
  not run them to "test".
- **Destroy state**: `just clean`, `just gc`, `just ggc` also drop the generations you would roll
  back to.

## Lessons from past changes

These all happened in this repository; they are the reason for the steps above.

- `063c31cc refactor(noctalia): hot-reload config via out-of-store symlink` - the baseline moved to
  an out-of-store symlink precisely so shell edits do not need a switch.
- `1546e54b chore(noctalia): move OSD and notifications to the bottom-right` and
  `e93cb979 fix(noctalia): keep the bar readable in light mode` - shell changes that parse fine, and
  that only a screenshot can judge.
- `495c3669 fix(xdg): order autostart apps after xdg-desktop-portal` - sandboxed apps raced the
  portal at login; order the unit instead of retrying the app.
- `33383414 fix(niri): match outputs by EDID to survive connector renumbering` - match outputs by
  EDID, not by connector name.
- `86f316cf fix: shoukei - noctalia - adjust brightness` - a per-host difference belongs in that
  host's `host-<host>.toml`, not in the shared baseline.
- `86161aeb fix: noctalia-shell - failed to unlock after suspend` and
  `b9610c47 fix(hypridle): skip lock while media is playing` - the idle and lock path is its own
  source of session bugs; test it after touching idle settings.
