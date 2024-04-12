# Editors

My editors:

1. Neovim
2. Emacs
3. Helix

And `Zellij` for a smooth and stable terminal experience.

## Tips

1. Many useful keys are already provided by vim, check vim/neovim's docs before you install a new
   plugin / reinvent the wheel.
1. After using Emacs/Neovim more skillfully, I strongly recommend that you read the official
   documentation of Neovim/vim:
   1. <https://vimhelp.org/>: The official vim documentation.
   1. <https://neovim.io/doc/user/>: Neovim's official user documentation.
1. Use Zellij for terminal related operations, and use Neovim/Helix for editing.
1. As for Emacs, Use its GUI version & terminal emulator `vterm` for terminal related operations.
1. Two powerful file search & jump tools:
1. Tree-view plugins are beginner-friendly and intuitive, but they're not very efficient.
1. **Search by the file path**: Useful when you're familiar with the project structure, especially
   on a large project.
1. **Search by the content**: Useful when you're familiar with the code.

## Tutorial

Type `:tutor`(`:Tutor` in Neovim) to learn the basics usage of vim/neovim.

## VIM's Cheetsheet

> Here only record my commonly used keys, to see **a more comprehensive cheetsheet**:
> <https://vimhelp.org/quickref.txt.html>

Both Emacs-Evil & Neovim are compatible with vim, sothe key-bindings described here are common in
both Emacs-Evil, Neovim & vim.

### Terminal Related

I mainly use Zellij for terminal related operations, here is its terminal shortcuts I use frequently
now:

| Action                    | Zellij's Shortcut |
| ------------------------- | ----------------- |
| Floating Terminal         | `Ctrl + p + w`    |
| Horizontal Split Terminal | `Ctrl + p + d`    |
| Vertical Split Terminal   | `Ctrl + p + n`    |
| Execute a command         | `!xxx`            |

### File Management

> <https://neovim.io/doc/user/usr_22.html>

> <https://vimhelp.org/editing.txt.html>

| Action                              |                                                  |
| ----------------------------------- | ------------------------------------------------ |
| Save selected text to a file        | `:w filename` (Will show `:'<,'>w filename`)     |
| Save and close the current buffer   | `:wq`                                            |
| Save all buffers                    | `:wa`                                            |
| Save and close all buffers          | `:wqa`                                           |
| Edit a file                         | `:e filename`(or `:e <TAB>` to show a file list) |
| Browse the file list                | `:Ex` or `:e .`                                  |
| Discard changes and reread the file | `:e!`                                            |

### Motion

> https://vimhelp.org/motion.txt.html

| Action                                              | Command                                            |
| --------------------------------------------------- | -------------------------------------------------- |
| Move to the start/end of the buffer                 | `gg`/`G`                                           |
| Move the line number 5                              | `5gg` / `5G`                                       |
| Move left/down/up/right                             | h/j/k/l or `5h`/`5j`/`5k`/`5l` or `Ctr-n`/`Ctrl-p` |
| Move to the matchpairs, default to `()`, `{}`, `[]` | `%`                                                |
| Move to the start/end of the line                   | `0` / `$`                                          |
| Move a sentence forward/backward                    | `(` / `)`                                          |
| Move a paragraph forward/backward                   | `{` / `}`                                          |
| Move a section forward/backward                     | `[[` / `]]`                                        |
| Jump to various positions                           | `'` + some other keys(neovim has prompt)           |

Text Objects:

- **sentence**: text ending at a '.', '!' or '?' followed by either the end of a line, or by a space
  or tab.
- **paragraph**: text ending at a blank line.
- **section**: text starting with a section header and ending at the start of the next section
  header (or at the end of the file). - The "`]]`" and "`[[`" commands stop at the '`{`' in the
  first column. This is useful to find the start of a function in a C/Go/Java/... program.

### Text Manipulation

Basics:

| Action                                  |                            |
| --------------------------------------- | -------------------------- |
| Delete the current character            | `x`                        |
| Paste the copied text                   | `p`                        |
| Delete the selection                    | `d`                        |
| Undo the last word                      | `CTRL-w`(in insert mode)   |
| Undo the last line                      | `CTRL-u`(in insert mode)   |
| Undo the last change                    | `u`                        |
| Redo the last change                    | `Ctrl + r`                 |
| Inserts the text of the previous insert | `Ctrl + a`                 |
| Repeat the last command                 | `.`                        |
| Toggle text's case                      | `~`                        |
| Convert to uppercase                    | `U` (visual mode)          |
| Convert to lowercase                    | `u` (visual mode)          |
| Align the selected content              | `:center`/`:left`/`:right` |

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
| Sort the selected lines                                                   | `:sort`        |
| Join Selection of Lines With Space                                        | `:join` or `J` |
| Join without spaces                                                       | `:join!`       |
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

| Action                           | Command                             |
| -------------------------------- | ----------------------------------- |
| Replace in selected area         | `:s/old/new/g`                      |
| Replace in current line          | Same as above                       |
| Replace all the lines            | `:% s/old/new/g`                    |
| Replace all the lines with regex | `:% s@\vhttp://(\w+)@https://\1@gc` |

1. `\v` means means that in the regex pattern after it can be used without backslash
   escaping(similar to python's raw string).
2. `\1` means the first matched group in the pattern.

### Replace in the specific lines

| Action                                    | Command                                |
| ----------------------------------------- | -------------------------------------- |
| From the 10th line to the end of the file | `:10,$ s/old/new/g` or `:10,$ s@^@#@g` |
| From the 10th line to the 20th line       | `:10,20 s/old/new/g`                   |
| Remove the trailing spaces                | `:% s/\s\+$//g`                        |

The postfix(flags) in the above commands:

1. `g` means replace all the matched strings in the current line/file.
2. `c` means ask for confirmation before replacing.
3. `i` means ignore case.

### Buffers, Windows and Tabs

> <https://neovim.io/doc/user/usr_08.html>

> <https://vimhelp.org/windows.txt.html>

- A buffer is the in-memory text of a file.
- A window is a viewport on a buffer.
- A tab page is a collection of windows.

| Action                              | Command                             |
| ----------------------------------- | ----------------------------------- |
| Split the window horizontally       | `:sp[lit]` or `:sp filename`        |
| Split the window horizontally       | `:vs[plit]` or `:vs filename`       |
| Switch to the next/previous window  | `Ctrl-w + w` or `Ctrl-w + h/j/k/l`  |
| Show all buffers                    | `:ls`                               |
| show next/previous buffer           | `]b`/`[b` or `:bn[ext]` / `bp[rev]` |
| New Tab(New Workspace in DoomEmacs) | `:tabnew`                           |
| Next/Previews Tab                   | `gt`/`gy`                           |

### History

| Action                   | Command |
| ------------------------ | ------- |
| Show the command history | `q:`    |
| Show the search history  | `q/`    |
