# Neovim (backup) — vim-style usage

Primary day-to-day editing is **Helix**; this file is the **vim/Neovim** quick reference and doc
pointers for when you reach for Neovim as a backup.

## Tips

1. Many motions already exist in vim — check vim/Neovim docs before adding plugins or reinventing
   wheels.
1. For deeper skill, read the official docs:
   1. <https://vimhelp.org/> — vim help.
   1. <https://neovim.io/doc/user/> — Neovim user manual.
1. Prefer **Zellij** for shells and panes; use **Helix** or **Neovim** for buffers and text.
1. Two powerful navigation modes on large codebases:
   1. **By path** — when you know the tree layout.
   1. **By content** — when you know what the code says.

## Tutorial

Type `:tutor` (or `:Tutor` in Neovim) for the built-in vim tutorial.

## Vim cheatsheet (common keys)

> For a fuller reference: <https://vimhelp.org/quickref.txt.html>

Emacs Evil, Neovim, and vim share the motions below.

### Terminal related

Zellij shortcuts used often:

| Action                    | Zellij shortcut |
| ------------------------- | --------------- |
| Floating terminal         | `Ctrl + p + w`  |
| Horizontal split terminal | `Ctrl + p + d`  |
| Vertical split terminal   | `Ctrl + p + n`  |
| Run a shell command       | `!xxx`          |

### File management

> <https://neovim.io/doc/user/usr_22.html>  
> <https://vimhelp.org/editing.txt.html>

| Action                        | Command                                      |
| ----------------------------- | -------------------------------------------- |
| Save selection to a file      | `:w filename` (shows `:'<,'>w filename`)     |
| Save and close current buffer | `:wq`                                        |
| Save all buffers              | `:wa`                                        |
| Save and close all buffers    | `:wqa`                                       |
| Edit a file                   | `:e filename` (or `:e <TAB>` for completion) |
| Browse files                  | `:Ex` or `:e .`                              |
| Discard changes and reload    | `:e!`                                        |

### Motion

> <https://vimhelp.org/motion.txt.html>

| Action                              | Command                                 |
| ----------------------------------- | --------------------------------------- |
| Start / end of buffer               | `gg` / `G`                              |
| Go to line 5                        | `5gg` / `5G`                            |
| Left / down / up / right            | `h` `j` `k` `l` (counts like `5j` work) |
| Jump to matchpairs `()`, `{}`, `[]` | `%`                                     |
| Start / end of line                 | `0` / `$`                               |
| Sentence forward / backward         | `(` / `)`                               |
| Paragraph forward / backward        | `{` / `}`                               |
| Section forward / backward          | `[[` / `]]`                             |
| Jump to marks                       | `'` + mark (Neovim may prompt)          |

Text objects:

- **Sentence**: ends at `.` `!` `?` plus line end or space/tab.
- **Paragraph**: ends at a blank line.
- **Section**: between section headers; `[[` / `]]` often stop at `{` in column 1 (handy in
  C/Go/Java).

### Text manipulation

Basics:

| Action                        | Command                        |
| ----------------------------- | ------------------------------ |
| Delete character under cursor | `x`                            |
| Put (paste)                   | `p`                            |
| Delete operator + motion      | `d`                            |
| Undo word (insert)            | `CTRL-w`                       |
| Undo line (insert)            | `CTRL-u`                       |
| Undo change                   | `u`                            |
| Redo                          | `Ctrl-r`                       |
| Repeat previous insert        | `Ctrl-a`                       |
| Repeat last change            | `.`                            |
| Toggle case                   | `~`                            |
| Uppercase (visual)            | `U`                            |
| Lowercase (visual)            | `u`                            |
| Align selection               | `:center` / `:left` / `:right` |

Misc:

| Action                   | Shortcut    |
| ------------------------ | ----------- |
| Character-wise visual    | `v`         |
| Line-wise visual         | `V`         |
| Block visual             | `<Ctrl-v>`  |
| Fold close / open        | `zc` / `zo` |
| Go to definition         | `gd`        |
| Go to references         | `gD`        |
| Comment line (if mapped) | e.g. `gcc`  |

| Action                              | Command        |
| ----------------------------------- | -------------- |
| Sort lines                          | `:sort`        |
| Join lines                          | `:join` or `J` |
| Join without spaces                 | `:join!`       |
| Insert at line start / end          | `I` / `A`      |
| Delete to end of line               | `D`            |
| Change to end of line (into insert) | `C`            |

Advanced patterns:

- Append to many lines: `:normal A<text>` (often after visual-block `Ctrl-v`).
- Neovim may pad short lines with spaces when block-appending past EOL.
- Delete last character on many lines: `:normal $x` over a visual selection.
- Delete last word on many lines: `:normal $bD`.

### Search

| Action                            | Command |
| --------------------------------- | ------- |
| Search forward / backward         | `/` `?` |
| Repeat search same / opposite dir | `n` `N` |

### Find and replace

| Action              | Command                            |
| ------------------- | ---------------------------------- |
| In visual selection | `:s/old/new/g`                     |
| Current line        | same                               |
| Whole buffer        | `:%s/old/new/g`                    |
| Regex example       | `:%s@\vhttp://(\w+)@https://\1@gc` |

Notes:

- `\v` — “very magic”, less backslash noise in the pattern.
- `\1` — first capture group.

### Specific line ranges

| Action                | Command examples                     |
| --------------------- | ------------------------------------ |
| Lines 10–end          | `:10,$s/old/new/g` or `:10,$s@^@#@g` |
| Lines 10–20           | `:10,20s/old/new/g`                  |
| Strip trailing spaces | `:%s/\s\+$//g`                       |

Flags: `g` all matches in range, `c` confirm each, `i` ignore case.

### Buffers, windows, tabs

> <https://neovim.io/doc/user/usr_08.html>  
> <https://vimhelp.org/windows.txt.html>

- **Buffer** — in-memory text for a file.
- **Window** — viewport on a buffer.
- **Tab page** — layout of windows.

| Action             | Command                        |
| ------------------ | ------------------------------ |
| Horizontal split   | `:sp` or `:sp filename`        |
| Vertical split     | `:vs` or `:vs filename`        |
| Next / prev window | `Ctrl-w w` or `Ctrl-w h/j/k/l` |
| List buffers       | `:ls`                          |
| Next / prev buffer | `]b` / `[b` or `:bn` / `:bp`   |
| New tab            | `:tabnew`                      |
| Next / prev tab    | `gt` / `gT`                    |

### History

| Action          | Command |
| --------------- | ------- |
| Command history | `q:`    |
| Search history  | `q/`    |
