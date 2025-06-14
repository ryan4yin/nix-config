# rime-data for flypy input method

Useful for Linux(fcitx5-rime) & macOS(squirrel).

## Linux(fcitx5-rime)

1. `~/.config/fcitx5/profile` is linked to
   [home/linux/gui/base/fcitx5/profile](/home/linux/gui/base/fcitx5/profile), which hardcode rime as
   the default input method, so you do not need to use fcitx-configtool to adjust fcitx5's input
   method.

## macOS(squirrel)

1. ` ~/Library/Rime/` is force linked to this rime-data, see
   [home/darwin/rime-squirrel.nix](/home/darwin/rime-squirrel.nix) for details.

## Docs about fcitx5

- [Fcitx5 - Arch Linux Wiki](https://wiki.archlinux.org/title/Fcitx5)
- [Fcitx5 - Official Wiki](https://fcitx-im.org/wiki/Fcitx_5/zh-cn)
- [discussion about using fcitx5 on hyprland](https://github.com/hyprwm/Hyprland/discussions/421)
- [hyprland issue about fcitx5](https://github.com/hyprwm/Hyprland/discussions/421)
