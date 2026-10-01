---
name: Nix Config Desktop
description:
  Use when changing the Niri/Noctalia desktop, the Wayland session, input method (fcitx5), theming,
  fonts, or desktop autostart in this repo. Covers which layer owns a setting, live reload vs a
  rebuild, and how to verify the result on screen.
---

# Changing the desktop

The desktop is a Niri + Noctalia Wayland session, shared by two hosts: `ai-niri` (hostName `ai`,
x86_64) and `shoukei-niri` (hostName `shoukei`, Apple Silicon). Shared config lives in
`home/linux/gui/**`; each host adds `hosts/<dir>/niri-hardware.kdl` and its own
`home/hosts/linux/<dir>.nix`. Run `hostname` to know which one you are on.

Most of the config is deployed as **out-of-store symlinks**, so an edit takes effect live, rolls
back with git, and needs no rebuild. Only the store layer needs one.

## Core rules

1. **Edit the config layer, not the store.** Niri KDL and the Noctalia baseline are symlinked out of
   store; editing them applies immediately. A rebuild is wasted time and hides the change behind a
   generation.
2. **Validate before trusting a reload.** A config that fails to parse does not crash the session:
   Niri keeps the last working config and shows a "Failed to parse the config file" notification.
   The edit silently does not apply, which is easy to misread as "my edit did nothing".
3. **Look at it.** Anything that renders (bar, OSD, notifications, wallpaper, corners) is not done
   until a screenshot shows it correct. A setting that parses is not a setting that looks right.
4. **Screenshots are the user's screen.** Capture as little as proves the change, keep the file out
   of the user's folders, and delete it afterwards (step 3).
5. **`just niri` is the user's to run.** It activates the machine you are on through
   `nixos-rebuild --sudo` and blocks on a password prompt.

## 1. Pick the layer

| Change                                        | Where it lives                                                | Applies                  |
| --------------------------------------------- | ------------------------------------------------------------- | ------------------------ |
| Niri compositor (binds, layout, window rules) | `home/linux/gui/niri/conf/*.kdl`                              | live                     |
| Niri per-host outputs                         | `hosts/<dir>/niri-hardware.kdl`                               | live                     |
| Noctalia shared baseline                      | `home/linux/gui/base/noctalia/config/config.toml`             | live                     |
| Noctalia per-host override                    | `home/hosts/linux/<dir>/noctalia.toml` (`host-<host>.toml`)   | store: needs `just niri` |
| Noctalia value saved by the Settings UI       | `~/.local/state/noctalia/settings.toml` (not in the repo)     | live, wins over the rest |
| Mozc dictionary                               | `home/linux/gui/base/fcitx5/mozc-config1.db`                  | live                     |
| fcitx5 profile and addons                     | `home/linux/gui/base/fcitx5/`                                 | store: needs `just niri` |
| Theme (catppuccin), fonts                     | `home/base/core/theme.nix`, `modules/nixos/desktop/fonts.nix` | store: needs `just niri` |
| Session, portal, and systemd wiring           | `modules/nixos/desktop/**`, `home/linux/gui/base/xdg/`        | store: needs `just niri` |

Noctalia's merge order and `[include]` are in
[home/linux/gui/base/README.md](../../../home/linux/gui/base/README.md). A per-host difference goes
in that host's override file, not in the shared baseline.

## 2. Edit and validate

```bash
niri validate                       # the live config and its whole include graph
noctalia config validate            # the merged config, as the running shell loads it
noctalia config validate ./home/linux/gui/base/noctalia/config/config.toml   # one file
```

Validate the **live** Niri config, not the repo copy: `config.kdl` includes `./niri-hardware.kdl`,
which only the host module places in `~/.config/niri/`, so `niri validate -c <repo path>` fails on
the missing include.

Confirm a file is really live before trusting a hot reload:

```bash
readlink -f ~/.config/niri/config.kdl      # must end in ~/nix-config/...
readlink -f ~/.config/noctalia/config.toml
```

`~/.config/...` points at a store path that is itself a symlink back into the repo. If it resolves
to a plain store file, it is not live and the change needs `just niri`.

If an edit does not show up:

- `niri msg action load-config-file` forces a Niri reload.
- `noctalia config export` prints the merged config that actually won; diff it against your edit.
- `~/.local/state/noctalia/settings.toml` loads last. A value saved through the Settings UI, or left
  over from an experiment, silently beats `config.toml`.

## 3. Verify on screen

```bash
niri msg action screenshot-window --path /tmp/opencode/check.png -p false   # focused window
niri msg action screenshot-screen --path /tmp/opencode/check.png -p false   # focused output
```

- Prefer `screenshot-window` when it proves the change. A full-screen capture includes whatever else
  is open: browser tabs, chats, credentials.
- `--path` must be absolute; it keeps the file out of `~/Pictures/Screenshots/`. `-p false` drops
  the pointer.
- Both actions also **replace the user's clipboard** with the image. There is no flag to avoid it,
  so say so when you take one.
- Inspect the PNG with your image-reading tool, show it to the user only when asked, never upload or
  share it, and delete it when done.

Capture the frame that proves the change: the bar or OSD for a shell edit, borders and corner radius
for a layout rule, the specific app for an input-method edit.

What a screenshot cannot show:

- `systemctl --user --failed` and `journalctl --user -b -p err` for a crashed shell or portal unit.
- `journalctl -u home-manager-$USER -b` after a store-layer change: Home Manager activates as a
  system unit here.
- `niri msg outputs` for mode, scale, and transform; `niri msg workspaces` and `niri msg windows`
  for layout.
- `fcitx5-remote -n` for the active input method.

## 4. Land and roll back

- Config layer: the repo file is the live file. Commit it; there is no rebuild and no generation. To
  undo, `git checkout -- <file>` (uncommitted) or `git revert` (committed), then let it reload.
- Store layer: the user runs `just niri`, then you verify as in step 3. To undo, boot the previous
  generation (`just history` lists them).
- If the session will not start at all, fix the file from a TTY. Niri's recovery only covers a bad
  reload, not a broken startup.

Do not "test" with commands that act on the session the user is looking at: `niri msg action quit`,
`niri msg action power-off-monitors`, `noctalia msg dpms-off`, `noctalia msg lock`.

## Why these rules exist

- `063c31cc refactor(noctalia): hot-reload config via out-of-store symlink` - the baseline is
  out-of-store precisely so shell edits do not need a switch.
- `1546e54b chore(noctalia): move OSD and notifications to the bottom-right` and
  `e93cb979 fix(noctalia): keep the bar readable in light mode` - changes that parse fine and only a
  screenshot can judge.
- `495c3669 fix(xdg): order autostart apps after xdg-desktop-portal` - sandboxed apps raced the
  portal at login; the fix orders the unit.
- `33383414 fix(niri): match outputs by EDID to survive connector renumbering` - match outputs by
  EDID, not by connector name.
