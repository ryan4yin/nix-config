# AstroNvim Configuration and Shortcuts

My Neovim config based on [AstroNvim](https://github.com/AstroNvim/AstroNvim).
For more details, visit the [AstroNvim website](https://astronvim.com/).

This document outlines neovim's configuration structure and various shortcuts/commands for efficient usage.

## Configuration Structure

| Description                                       | Standard Location                           | My Location                                                               |
| ------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------- |
| Neovim's config                                   | `~/.config/nvim`                            | AstroNvim's github repository, referenced as a flake input in this flake. |
| AstroNvim's user configuration                    | `$XDG_CONFIG_HOME/astronvim/lua/user`       | [./astronvim_user/](./astronvim_user/)                                    |
| Plugins installation directory (lazy.nvim)        | `~/.local/share/nvim/`                      | The same as standard location, generated and managed by lazy.nvim.        |
| LSP servers, DAP servers, linters, and formatters | `~/.local/share/nvim/mason/`(by mason.nvim) | [./default.nix](./default.nix), installed by nix.                         |

## Screenshots

![](/_img/astronvim_2023-07-13_00-39.webp)
![](/_img/hyprland_2023-07-29_2.webp)

## Visual Modes

| Action                   | Shortcut                                 |
| ------------------------ | ---------------------------------------- |
| Toggle visual mode       | `v`                                      |
| Toggle visual block mode | `<Ctrl> + v` (select a block vertically) |

## Incremental Selection

Provided by nvim-treesitter.

| Action            | Shortcut |
| ----------------- | -------- |
| init selection    | `gnn`    |
| node incremental  | `grn`    |
| scope incremental | `grc`    |
| node decremental  | `grm`    |

## Text Manipulation

- Add at the end of multiple lines: `:normal A<text>`

  - Execute `A<text>` on each line
  - `A` appends text at the end of each line
  - Select lines using visual mode first

- Add at the end of visual block: `:A<text>`
  - Append text at the end of each line in the selected block(visual block mode)
  - If position exceeds line end, neovim adds spaces automatically

## Commands & Shortcuts

| Action                        | Shortcut       |
| ----------------------------- | -------------- |
| Learn Neovim's Basics         | `:Tutor`       |
| Open file explorer            | `<Space> + e`  |
| Focus Neotree to current file | `<Space> + o`  |
| Floating Terminal             | `<Space> + tf` |
| Horizontal Split Terminal     | `<Space> + th` |
| Vertical Split Terminal       | `<Space> + tv` |
| Open IPython REPL             | `<Space> + tp` |
| Toggle line wrap              | `<Space> + uw` |
| Show line diagnostics         | `gl`           |
| Show function/variable info   | `K`            |
| Go to definition              | `gd`           |
| References of a symbol        | `gr`           |

## Window Navigation

- Switch between windows: `<Ctrl> + h/j/k/l`
- Resize windows: `<Ctrl> + Up/Down/Left/Right`
  - Note: On macOS, conflicts with system shortcuts
  - Disable in System Preferences -> Keyboard -> Shortcuts -> Mission Control

## Splitting and Buffers

| Action                | Shortcut      |
| --------------------- | ------------- |
| Horizontal Split      | `\`           |
| Vertical Split        | `\|`          |
| Next Buffer (Tab)     | `]b`          |
| Previous Buffer (Tab) | `[b`          |
| Close Buffer          | `<Space> + c` |

## Editing and Formatting

| Action                                                | Shortcut       |
| ----------------------------------------------------- | -------------- |
| Toggle buffer auto formatting                         | `<Space> + uf` |
| Format Document                                       | `<Space> + lf` |
| Code Actions                                          | `<Space> + la` |
| Rename                                                | `<Space> + lr` |
| Opening LSP symbols                                   | `<Space> + lS` |
| Comment Line(support multiple lines)                  | `<Space> + /`  |
| Open filepath/URL at cursor(neovim's builtin command) | `gx`           |
| Find files by name (fzf)                              | `<Space> + ff` |
| Grep string in files (ripgrep)                        | `<Space> + fw` |

## Sessions

| Action                         | Shortcut       |
| ------------------------------ | -------------- |
| Save Session                   | `<Space> + Ss` |
| Last Session                   | `<Space> + Sl` |
| Delete Session                 | `<Space> + Sd` |
| Search Session                 | `<Space> + Sf` |
| Load Current Directory Session | `<Space> + S.` |

## Debugging

Press `<Space> + D` to view available bindings and options.

## Find and Replace

| Action                   | Command                             |
| ------------------------ | ----------------------------------- |
| Replace in selected area | `:s/old/new/g`                      |
| Replace in current line  | Same as above                       |
| Replace in whole file    | `:% s/old/new/g`                    |
| Replace with regex       | `:% s@\vhttp://(\w+)@https://\1@gc` |

1. `\v` means means that in the regex pattern after it can be used without backslash escaping(similar to python's raw string).
2. `\1` means the first matched group in the pattern.

## Replace in the specific lines

| Action                                    | Command                                |
| ----------------------------------------- | -------------------------------------- |
| From the 10th line to the end of the file | `:10,$ s/old/new/g` or `:10,$ s@^@#@g` |
| From the 10th line to the 20th line       | `:10,20 s/old/new/g`                   |

The postfix(flags) in the above commands:

1. `g` means replace all the matched strings in the current line/file.
2. `c` means ask for confirmation before replacing.
3. `i` means ignore case.

## Search and Replace Globally

| Description                                                  | Shortcut                                                         |
| ------------------------------------------------------------ | ---------------------------------------------------------------- |
| Open spectre.nvim search and replace panel                   | `<Space> + ss`                                                   |
| Search and replace in command line(need install `sad` first) | `find -name "*.nix" \| sad '<pattern>' '<replacement>' \| delta` |

## Surrounding Characters

| Action                        | Shortcut | Description                                    |
| ----------------------------- | -------- | ---------------------------------------------- |
| Add surrounding characters    | `ysiw'`  | Add `'` around the word under cursor           |
| Delete surrounding characters | `ds'`    | Delete `'` around the word under cursor        |
| Change surrounding characters | `cs'"`   | Change `'` to `"` around the word under cursor |

## Text Manipulation

| Action                                 |               |
| -------------------------------------- | ------------- |
| Join Selection of Lines With Space     | `:join`       |
| Join without spaces                    | `:join!`      |
| Join with LSP intelligence(treesj)     | `<Space> + j` |
| Split Line into Multiple Lines(treesj) | `<Space> + s` |

## Convert Text Case

| Action               |     |
| -------------------- | --- |
| Toggle text's case   | `~` |
| Convert to uppercase | `U` |
| Convert to lowercase | `u` |

## Miscellaneous

| Action                       |                                              |
| ---------------------------- | -------------------------------------------- |
| Save selected text to a file | `:w filename` (Will show `:'<,'>w filename`) |
| Show all Yank History        | `:<Space> + yh`                              |
| Show undo history            | `:<Space> + uh`                              |

## Additional Resources

For more detailed information and advanced usage, refer to:

1. [AstroNvim walkthrough](https://astronvim.com/Basic%20Usage/walkthrough)
2. [./astronvim_user/mapping.lua](./astronvim_user/mappings.lua)
3. All the plugins' documentations
