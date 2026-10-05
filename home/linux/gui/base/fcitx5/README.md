# fcitx5 - IME

fcitx5 is enabled in `default.nix` with the [flypy](https://flypy.com/) Rime schema (Chinese),
`fcitx5-mozc-ut` (Japanese), and `fcitx5-hangul` (Korean), alongside the US keyboard layouts. The
Rime data comes from the `rime-data-flypy` package in `nur-ryan4yin` (`pkgs/rime-data-flypy`); the
whole Rime configuration, including the `fcitx5-rime` addon and the user customisation shared with
macOS, lives in `home/base/gui/rime/` (see its README).

## Available Configurations

- `fcitx5/config` (global config) → `~/.config/fcitx5/config`; pins `AltTriggerKeys` (see below).
- `profile` → Symlink will be created at: `~/.config/fcitx5/profile`
- `mozc-config1.db` (Mozc config) → Symlink will be created at: `~/.config/mozc/config1.db`
  - Main changes from the defaults: use half-width for all alphabets, numbers, and punctuation.
  - https://github.com/google/mozc/blob/2.30.5544.102/docs/configurations.md

## Shift keys

- Right Shift: switch CN/EN, through Rime.
- Left Shift: plain modifier.
- Ctrl+Space: switch CN/EN (fcitx5's `TriggerKeys`).

fcitx5's `AltTriggerKeys` (the "temporarily toggle input method" hotkey) defaults to `Shift_L`, so
it would toggle on left Shift; it is empty here. The Rime side, `Shift_R` as `commit_code` and
`Shift_L` as `noop`, is in `home/base/gui/rime/flypy.custom.yaml` (shared with macOS).
