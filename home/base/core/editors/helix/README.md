# Helix (primary) — Kakoune-style usage

Neovim is powerful and has a very active community. This config still enables Neovim as a **backup**
editor (vim-style muscle memory, `:help`, and occasional plugin workflows).

Helix is the **primary** TUI editor here: opinionated, batteries-included (LSP, tree-sitter, picker,
multi-cursor, surround), and a smaller moving part than a large Neovim plugin stack.

## Tips

1. This flake sets `$EDITOR` / `$VISUAL` to **`hx`** by default. For security-sensitive edits
   (privileged files, unfamiliar binaries, secrets), prefer **`nvim --clean`** — `$SUDO_EDITOR` uses
   it so `sudoedit` stays minimal; invoke it yourself in other trust-boundary cases.
1. Helix is **selection-first** (like Kakoune): extend a selection, then run an action (`d`, `c`,
   `y`, …). A lone cursor is a zero-width selection.
1. Read the official docs before reinventing workflows:
   1. <https://docs.helix-editor.com/> — documentation home (links to usage, keymap, configuration).
   1. <https://docs.helix-editor.com/usage.html> — modes, buffers, motions overview.
   1. <https://docs.helix-editor.com/keymap.html> — full default keybindings.
   1. <https://docs.helix-editor.com/commands.html> — typable commands (`:` prompt).
   1. <https://docs.helix-editor.com/configuration.html> — `config.toml`, themes, remaps.
   1. <https://github.com/helix-editor/helix/wiki> — install tips, language servers, FAQ.
1. Prefer **Zellij** for shells and panes; use **Helix** for buffers and text.
1. On large codebases, navigation is often **by picker** (`Space f`, symbols, workspace search) or
   **by LSP** (`g` goto mode), complementing motion-based editing.
1. After **git** operations (`checkout`, `merge`, `pull`, `rebase`) or whenever many files changed
   on disk, run **`:reload-all`** (alias **`:rla`**) so every open buffer is refreshed from disk in
   one step — much faster than revisiting each file or restarting Helix.

## Tutorial

Run `:tutor` inside Helix, or `hx --tutor` from the shell
([tutor source](https://github.com/helix-editor/helix/blob/master/runtime/tutor)).

## Helix cheatsheet (common keys)

> Full reference: <https://docs.helix-editor.com/keymap.html>  
> Typable commands: <https://docs.helix-editor.com/commands.html>

### Terminal related

Zellij shortcuts used often (same idea as in the Neovim notes):

| Action                    | Zellij shortcut |
| ------------------------- | --------------- |
| Floating terminal         | `Ctrl + p + w`  |
| Horizontal split terminal | `Ctrl + p + d`  |
| Vertical split terminal   | `Ctrl + p + n`  |

In Helix, `|` / `!` and variants pipe or insert shell output on selections (see **Changes**).

This flake’s Helix Home Manager module keeps **almost all default keys**; the only remap is
**`Ctrl+Shift+o`** → jump backward, because Zellij uses **`Ctrl+o`** for Session (see
`home/base/core/editors/helix/default.nix`). For other Zellij clashes, use **locked mode**
(`Ctrl+g`), **`:`** commands, or the built-in **`Space`** menu.

### Command mode (`:`)

> <https://docs.helix-editor.com/commands.html>

| Action                 | Command examples                                                     |
| ---------------------- | -------------------------------------------------------------------- |
| Write / write all      | `:w` / `:wa`                                                         |
| Quit view / quit all   | `:q` / `:qa` — add `!` to discard changes                            |
| Write and quit         | `:wq`, `:x`                                                          |
| Write all and quit all | `:wqa`, `:xa`                                                        |
| Open file              | `:open path`, `:e path`                                              |
| Next / previous buffer | `:bn` / `:bp` (also `gn` / `gp` in normal)                           |
| Close buffer           | `:bc` (add `!` to force)                                             |
| Reload from disk       | `:reload` (current buffer); `:reload-all` / **`:rla`** (all buffers) |
| Change directory / pwd | `:cd` / `:pwd`                                                       |
| Split open file        | `:vs path`, `:hs path`                                               |

### Movement (normal mode)

| Action                | Keys / notes                                        |
| --------------------- | --------------------------------------------------- |
| Arrow keys            | `h` `j` `k` `l`                                     |
| Words                 | `w` `b` `e` — `W` `B` `E` for WORD-style            |
| Find char / till char | `f` `F` `t` `T` (not limited to current line)       |
| Line / file           | `Home` / `End`; `gg` start or goto line; `G` line   |
| Half / full page      | `Ctrl-u` / `Ctrl-d`; `Ctrl-b` / `Ctrl-f`            |
| Jumplist              | `Ctrl-o` back, `Ctrl-i` forward; `Ctrl-s` save spot |

### Selection & changes

| Action                 | Keys / notes                                                      |
| ---------------------- | ----------------------------------------------------------------- |
| Extend selections      | `v` select mode; motions extend instead of moving                 |
| Line selection         | `x` extend line; `X` line bounds                                  |
| Select all / regex     | `%`; `s` regex in selections; `S` split on regex                  |
| Undo / redo            | `u` / `U`                                                         |
| Delete / change / yank | `d` / `c` / `y` — acts on selection                               |
| Paste                  | `p` / `P`; registers `"` …                                        |
| Insert                 | `i` `a` `I` `A` `o` `O`                                           |
| Indent / format        | `>` / `<`; `=` format (LSP)                                       |
| Case                   | `~` toggle; lower/upper case via grave / `Alt-grave` (see keymap) |
| Join lines             | `J`; `Alt-J` join keeping space                                   |

### Search

| Action               | Keys                                     |
| -------------------- | ---------------------------------------- |
| Search / reverse     | `/` / `?`                                |
| Next / prev match    | `n` / `N`                                |
| Selection as pattern | `*` (word bounds); `Alt-*` raw selection |

Use **extend mode** (`v`) with `n` / `N` to add matches to multi-cursors
([keymap](https://docs.helix-editor.com/keymap.html#select--extend-mode)).

### Replace / multi-occur edits

Helix has no vim-style `:%s` with preview. Typical patterns:

- Select matches with `s` or search, then `c` to change all selections at once.
- Workspace-wide search: `Space /` (global search picker).
- Heavy refactors: external tools or another pane (see **Differences** below).

### Goto mode (`g` then …)

| Action               | Keys (after `g`) |
| -------------------- | ---------------- |
| File start / end     | `g` / `e`        |
| Line start / end     | `h` / `l`        |
| File / URL           | `f`              |
| First non-whitespace | `s`              |
| Definition / refs    | `d` / `r` (LSP)  |
| Type / impl          | `y` / `i` (LSP)  |
| Next / prev buffer   | `n` / `p`        |

Also: `gd` / `gD` definition/declaration-style jumps where bound.

### Match mode (`m` …)

Surround and textobjects: see <https://docs.helix-editor.com/surround.html> and
<https://docs.helix-editor.com/textobjects.html>. Matching bracket: `mm` (tree-sitter).

### Window mode (`Ctrl-w` then …)

| Action           | Keys            |
| ---------------- | --------------- |
| Next window      | `w`             |
| Vertical split   | `v`             |
| Horizontal split | `s`             |
| Focus splits     | `h` `j` `k` `l` |
| Close / only     | `q` / `o`       |

### Space mode (`Space` then …)

| Action               | Keys               |
| -------------------- | ------------------ |
| File picker (roots)  | `f`                |
| File picker (cwd)    | `F`                |
| Buffer picker        | `b`                |
| Global search        | `/`                |
| Command palette      | `?`                |
| Hover docs (LSP)     | `k`                |
| Symbols / workspace  | `s` / `S`          |
| Diagnostics          | `d` / `D`          |
| Clipboard yank/paste | `y` / `p` variants |

Picker movement: <https://docs.helix-editor.com/pickers.html>.

### Minor modes from normal

| Mode        | Key       |
| ----------- | --------- |
| Command     | `:`       |
| View scroll | `z` / `Z` |
| Goto        | `g`       |
| Match       | `m`       |
| Window      | `Ctrl-w`  |

Some bindings need an **LSP** or **tree-sitter** grammar; see notes on the keymap page.

## Differences between Neovim and Helix

1. Selecting first, then action.
   1. Helix: delete 2 words: move/select with `w` … then `d`. You see the selection before the
      action.
   2. Neovim: delete 2 words: `d` then `2w`. No visual feedback before the action runs.
1. Helix — modern built-in features: LSP, tree-sitter, fuzzy finder, multi-cursors, surround, and
   more.
   1. The same is available in Neovim, but usually via plugins you choose and maintain.
1. Helix is built in Rust from scratch: smaller codebase, modern defaults. No VimScript, no Lua in
   user config.
   1. Neovim carries Vim heritage (VimScript) and Lua-heavy customization.
1. Neovim has a huge plugin ecosystem.
   1. Helix is newer; a stable plugin system is still evolving:
      <https://github.com/helix-editor/helix/pull/8675>
1. Neovim has an integrated terminal (similar in spirit to VS Code’s).
   1. Helix does not ship one; use Zellij / tmux / terminal features instead.
   1. <https://github.com/helix-editor/helix/issues/1976#issuecomment-1091074719>
   1. <https://github.com/helix-editor/helix/pull/4649>
1. Helix has no built-in tree panel; pair with **Yazi**, ranger, or Broot and open files from there.
   1. A tree view may arrive with plugins later; many users rely on the file picker instead.
1. Global substitution is weaker in Helix; run replacements in another pane (Zellij) or an external
   tool when needed.
   1. <https://github.com/helix-editor/helix/issues/196>
   1. Neovim’s `:s` with preview remains strong for interactive refactors; external tools (e.g.
      <https://github.com/ms-jpq/sad>) can fill gaps in Helix-centric flows.
1. Complexity vs batteries-included tradeoffs:
   <https://github.com/helix-editor/helix/discussions/6356>

Using **Helix** (and Neovim when useful) inside **Yazi** and **Zellij** keeps editing, files, and
panes explicit and scriptable — different from a single IDE window, but very composable.

Helix nudges you away from reproducing VS Code/JetBrains inside one process; Neovim remains there
when you want that depth.
