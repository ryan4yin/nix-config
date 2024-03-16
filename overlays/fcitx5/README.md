# rime-data for flypy input method

Useful for Linux(fcitx5-rime) & macOS(squirrel).

## Linux(fcitx5-rime)

1. pay attention to the `rm -rf .local/share/fcitx5/rime/`, which may contains some auto generated
   rime config files, which may cause flypy not the default scheme for rime
2. manage `~/.config/fcitx5/profile` in ../home/hyprland/default.nix, which hardcode rime as the
   default input method, so you do not need to use fcitx-configtool to set rime as the default input
   method.
3. fcitx5-rime still cannot use on vscode & chrome now... need more time to figure out why and
   resolve it.

## macOS(squirrel)

1. pay attention to the `rm -rf ~/Library/Rime/`, which may contains some auto generated rime config
   files.

## Docs about fcitx5

- [Fcitx5 - Arch Linux Wiki](https://wiki.archlinux.org/title/Fcitx5)
- [Fcitx5 - Official Wiki](https://fcitx-im.org/wiki/Fcitx_5/zh-cn)
- [discussion about using fcitx5 on hyprland](https://github.com/hyprwm/Hyprland/discussions/421)
- [hyprland issue about fcitx5](https://github.com/hyprwm/Hyprland/discussions/421)
