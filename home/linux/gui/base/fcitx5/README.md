# fcitx5 - IME

fcitx5 is enabled in `default.nix` with the [flypy](https://flypy.com/) Rime schema (Chinese),
`fcitx5-mozc-ut` (Japanese), and `fcitx5-hangul` (Korean), alongside the US keyboard layouts. The
Rime data ships in the [`overlays/fcitx5`](../../../../../overlays/fcitx5/) overlay.

## Available Configurations

- `profile` → Symlink will be created at: `~/.config/fcitx5/profile`
- `mozc-config1.db` (Mozc config) → Symlink will be created at: `~/.config/mozc/config1.db`
  - Main changes from the defaults: use half-width for all alphabets, numbers, and punctuation.
  - https://github.com/google/mozc/blob/2.30.5544.102/docs/configurations.md
