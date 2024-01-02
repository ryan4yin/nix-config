# Emacs Editor

- Framework: <https://github.com/doomemacs/doomemacs>
  - key bindings: <https://github.com/doomemacs/doomemacs/blob/master/modules/config/default/%2Bevil-bindings.el>
- Chinese(rime) support: <https://github.com/DogLooksGood/emacs-rime>
- modal editing:
  - <https://github.com/emacs-evil/evil>: evil mode, enabled by default in doom-emacs.
  - <https://github.com/meow-edit/meow>

Emacs daemon:

- <https://github.com/nix-community/home-manager/blob/master/modules/services/emacs.nix>
- <https://github.com/LnL7/nix-darwin/blob/1a41453cba42a3a1af2fff003be455ddbd75386c/modules/services/emacs.nix>

## Install or Update

After deploying this nix flake, run the following command to install or update emacs:

```bash
doom sync
```

## Terminal Related

zellij provides a more powerful and stable terminal experience, so here is zellij's terminal shortcuts I use frequently now:

| Action                    | Zellij's Shortcut  |
| ------------------------- | ------------------ |
| Floating Terminal         | `Ctrl + <p> + <w>` |
| Horizontal Split Terminal | `Ctrl + <p> + <d>` |
| Vertical Split Terminal   | `Ctrl + <p> + <n>` |
| Open file tree sidebar    | `SPC + o + p`      |

## Visual Modes

The same as neovim/vim:

| Action                   | Shortcut                                 |
| ------------------------ | ---------------------------------------- |
| Toggle visual mode       | `v`                                      |
| Toggle visual block mode | `<Ctrl> + v` (select a block vertically) |

## Text Manipulation

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
  - `D` deletes from cursor to the end of line

## Splitting and Buffers

| Action                | Shortcut          |
| --------------------- | ----------------- |
| Next Buffer (Tab)     | `]b`              |
| Previous Buffer (Tab) | `[b`              |
| Buffer List           | `<Space> + ,`     |
| Save all buffers(Tab) | `<Space> + b + S` |

## Editing and Formatting

| Action                                   | Shortcut            |
| ---------------------------------------- | ------------------- |
| Format Document                          | `<Space> + cf`      |
| Code Actions                             | `<Space> + ca`      |
| Rename                                   | `<Space> + cr`      |
| Opening LSP symbols                      | `<Space> + cS`      |
| Comment Line(support multiple lines)     | `<Space> + /`       |
| Open filepath/URL at cursor              | `gf`                |
| Find files by keyword in path            | `<Space> + <Space>` |
| Grep string in files (vertico + ripgrep) | `<Space> + sd`      |

## Text Manipulation

| Action                             |     |
| ---------------------------------- | --- |
| Join Selection of Lines With Space | `J` |

## Search & replace

```bash
SPC s p foo C-; E C-c C-p :%s/foo/bar/g RET Z Z
```

1. `SPC s p`: search in project
1. `foo`: the keyword to search
1. `C-; E`: exports what you’re looking at into a new buffer in grep-mode
1. `C-c C-p` to run wgrep-change-to-wgrep-mode to make the search results writable.
1. `:%s/foo/bar/g RET`: replace in the current buffer(just like neovim/vim)
1. `Z Z`: to write all the changes to their respective files
