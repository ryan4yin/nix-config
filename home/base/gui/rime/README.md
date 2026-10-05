# Rime (flypy) customisation

Personal Rime setup for the [flypy](https://flypy.com/) (小鹤音形) schema, shared by fcitx5-rime
(Linux) and Squirrel (macOS) so both behave the same.

## Files

- `flypy.custom.yaml`: the preferences, layered by Rime on top of the shared rime-data.
- `flypy_user.txt`: the user dictionary (custom phrases, symbols, missing characters).
- `default.nix`: per-platform wiring (see that file for the details).

The schema data comes from the `rime-data-flypy` package in `nur-ryan4yin` and stays untouched, so
updates survive. Personal preferences and the dictionary live here. On macOS the shared data
includes an empty `flypy_user.txt`, so the user files set `home.fileOverlapResolution = "override"`
to win over it.

## Preferences

- Right Shift switches CN/EN. Left Shift stays a plain modifier; Ctrl+Space also switches (fcitx5 on
  Linux, the system input-source shortcut on macOS).
- Shift+Space does not toggle full/half width.
- `[ ] { }` produce corner brackets `「」『』`.

These sit in a schema-level patch rather than `default.custom.yaml` so they also override the
`default` preset and flypy's own bindings, and to avoid colliding with the `default.custom.yaml`
that ships in Squirrel's user directory.

## Hotkeys

The flypy schema brings its own bindings. Two worth remembering:

- Ctrl+J toggles simplified/traditional Chinese (简繁).
- Ctrl+. toggles Chinese/ASCII punctuation (中英标点).

## Applying changes

`flypy.custom.yaml` is a store symlink with an epoch mtime, so Rime does not redeploy when it
changes. Remove `build/` and reload:

```sh
# Linux
rm -rf ~/.local/share/fcitx5/rime/build
fcitx5-remote -r

# macOS: remove build/, then restart Squirrel
rm -rf ~/Library/Rime/build
```
