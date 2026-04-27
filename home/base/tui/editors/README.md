# Editor tooling packages (heavy dependencies)

This directory intentionally holds **only** [`packages.nix`](./packages.nix): language servers,
formatters, compilers, and other editor-adjacent tools that pull in a large closure.

Editor programs, keymaps, `$EDITOR` defaults, and usage docs live under
[`../../core/editors/`](../../core/editors/README.md) (Helix, Neovim backup, glossary, cheatsheets).

[`default.nix`](./default.nix) imports `./packages.nix` so `home/base/tui` can keep pulling in
tooling without mixing it into `core/editors`.
