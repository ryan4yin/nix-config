# Editors

Shared editor configuration and **usage notes** for terminal-focused editing.

## Roles

- **Helix** (`helix/`): Primary TUI editor — batteries-included, small attack surface. `$EDITOR` /
  `$VISUAL` default to `hx` (`session-env.nix`).
- **Neovim** (`neovim/`): Backup editor — classic vim-style workflow and `:help` when needed. For
  privileged edits (`sudoedit`) and other security-sensitive inputs, `$SUDO_EDITOR` is
  `nvim --clean`; use that explicitly when `$EDITOR` must avoid user config/plugins.

Terminal layout and files: **Zellij** and **Yazi** live under `core/zellij/` and `core/yazi.nix`
(not in this folder).

## Docs

- [`helix/README.md`](./helix/README.md) — Helix basics, cheatsheet, official doc links, Helix vs
  Neovim notes.
- [`neovim/README.md`](./neovim/README.md) — Vim/Neovim basics, cheatsheet, and official doc links.

Nix modules in `helix/` and `neovim/` enable each editor via Home Manager. Language servers and
other heavy editor-related packages are listed in
[`../../tui/editors/`](../../tui/editors/README.md) (imported from `home/base/tui`).

Editor terminology (LSP, tree-sitter): [`Glossary.md`](./Glossary.md).
