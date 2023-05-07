# Fcitx5-Rime + Flypy

- fcitx5 input method - currently not work in vscode, and failed to add flypy input method

## Hisotry Problems

1. pay attention to the `rm -rf .local/share/fcitx5/rime/`, which may contains some auto generated rime config files, which may cause flypy not the default scheme for rime
2. manage `~/.config/fcitx5/profile` in ../home/hyprland/default.nix, which hardcode rime as the default input method, so you do not need to use fcitx-configtool to set rime as the default input method.
3. fcitx5-rime still cannot use on vscode & chrome now... need more time to figure out why and resolve it.
