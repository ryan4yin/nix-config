# Editors

My editors:

1. Neovim
2. Emacs
3. Helix

And `Zellij` for a smooth and stable terminal experience.

## Tutorial

Type `:tutor`(`:Tutor` in Neovim) to learn the basics usage of vim/neovim.

## VIM's Cheetsheet

> Here only record my commonly used keyboard keys, to see **a more comprehensive cheetsheet**: <https://github.com/rtorr/vim-cheat-sheet>

Both Emacs-Evil & Neovim are compatible with vim, sothe key-bindings described here are common in both Emacs-Evil, Neovim & vim.

### Terminal Related

I mainly use Zellij for terminal related operations, here is its terminal shortcuts I use frequently now:

| Action                    | Zellij's Shortcut |
| ------------------------- | ----------------- |
| Floating Terminal         | `Ctrl + p + w`    |
| Horizontal Split Terminal | `Ctrl + p + d`    |
| Vertical Split Terminal   | `Ctrl + p + n`    |

### File Management

| Action                            |                                              |
| --------------------------------- | -------------------------------------------- |
| Save selected text to a file      | `:w filename` (Will show `:'<,'>w filename`) |
| Save and close the current buffer | `:wq`                                        |
| Save all buffers                  | `:wa`                                        |
| Save and close all buffers        | `:wqa`                                       |

### Text Manipulation

Basics:

| Action                                              |                                |
| --------------------------------------------------- | ------------------------------ |
| Move to the start/end of the buffer                 | `gg`/`G`                       |
| Move the line number 5                              | `5gg` / `5G`                   |
| Move left/down/up/right                             | h/j/k/l or `5h`/`5j`/`5k`/`5l` |
| Move to the matchpairs, default to `()`, `{}`, `[]` | `%`                            |
| Delete the current character                        | `x`                            |
| Delete the selection                                | `d`                            |
| Undo the last change                                | `u`                            |
| Redo the last change                                | `Ctrl + r`                     |
| Toggle text's case | `~` |
| Convert to uppercase | `U` |
| Convert to lowercase | `u` |

Misc:

| Action                        | Shortcut                                 |
| ----------------------------- | ---------------------------------------- |
| Toggle visual mode            | `v` (lower case v)                       |
| Select the current line       | `V` (upper case v)                       |
| Toggle visual block mode      | `<Ctrl> + v` (select a block vertically) |
| Fold the current code block   | `zc`                                     |
| Unfold the current code block | `zo`                                     |
| Jump to Definition            | `gd`                                     |
| Jump to References            | `gD`                                     |
| (Un)Comment the current line  | `gcc`                                    |

| Action                                                                    |                |
| ------------------------------------------------------------------------- | -------------- |
| Join Selection of Lines With Space                                        | `:join` or `J` |
| Join without spaces                                                       | `:join!`       |
| Move to the start/end of the line                                         | `0` / `$`      |
| Enter Insert mode at the start/end of the line                            | `I` / `A`      |
| Delete from the cursor to the end of the line                             | `D`            |
| Delete from the cursor to the end of the line, and then enter insert mode | `C`            |

Advance Techs:

- Add at the end of multiple lines: `:normal A<text>`

  - Execublock: `:A<text>`
  - visual block mode(ctrl + v)
  - Append text at the end of each line in the selected block
  - If position exceeds line end, neovim adds spaces automatically

- Delete the last char of multivle lines: `:normal $x`

  - Execute `$x` on each line
  - visual mode(v)
  - `$` moves cursor to the end of line
  - `x` deletes the character under the cursor

- Delete the last word of multiple lines: `:normal $bD`
  - Execute `$bD` on each line
  - visual mode(v)
  - `$` moves cursor to the end of line
  - `b` moves cursor to the beginning of the last word

### Search

| Action                                                | Command   |
| ----------------------------------------------------- | --------- |
| Search forward/backword for a pattern                 | `/` / `?` |
| Repeat the last search in the same/opposite direction | `n` / `N` |

### Find and Replace

| Action                   | Command                             |
| ------------------------ | ----------------------------------- |
| Replace in selected area | `:s/old/new/g`                      |
| Replace in current line  | Same as above                       |
| Replace in whole file    | `:% s/old/new/g`                    |
| Replace with regex       | `:% s@\vhttp://(\w+)@https://\1@gc` |

1. `\v` means means that in the regex pattern after it can be used without backslash escaping(similar to python's raw string).
2. `\1` means the first matched group in the pattern.

### Replace in the specific lines

| Action                                    | Command                                |
| ----------------------------------------- | -------------------------------------- |
| From the 10th line to the end of the file | `:10,$ s/old/new/g` or `:10,$ s@^@#@g` |
| From the 10th line to the 20th line       | `:10,20 s/old/new/g`                   |

The postfix(flags) in the above commands:

1. `g` means replace all the matched strings in the current line/file.
2. `c` means ask for confirmation before replacing.
3. `i` means ignore case.

### Buffers, Windows and Tabs

- A buffer is the in-memory text of a file.
- A window is a viewport on a buffer.
- A tab page is a collection of windows.

| Action                              | Command                             |
| ----------------------------------- | ----------------------------------- |
| Show all buffers                    | `:ls`                               |
| show next/previous buffer           | `]b`/`[b` or `:bn[ext]` / `bp[rev]` |
| Split the window horizontally       | `:sp[lit]`                               |
| Split the window horizontally       | `:vs[plit]`                              |
| New Tab(New Workspace in DoomEmacs) | `:tabnew`                           |
| Next/Previews Tab                   | `gt`/`gT`                           |
