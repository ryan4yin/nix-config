# Emacs Editor

## Why emacs?

1. Explore the unknown, just for fun!
2. Org Mode
3. Lisp Coding
4. A top-level tutorial for Emacs(Chinese): <https://nyk.ma/tags/emacs/>
5. A Beginner's Guide to Emacs(Chinese):
   <https://github.com/emacs-tw/emacs-101-beginner-survival-guide>

## Screenshot

![](/_img/emacs-2024-01-07.webp)

## Useful Links

- Framework: <https://github.com/doomemacs/doomemacs>
  - key bindings:
    - source code:
      <https://github.com/doomemacs/doomemacs/blob/master/modules/config/default/%2Bevil-bindings.el>
    - docs: <https://github.com/doomemacs/doomemacs/blob/master/modules/editor/evil/README.org>
  - module index: <https://github.com/doomemacs/doomemacs/blob/master/docs/modules.org>
- LSP Client: <https://github.com/manateelazycat/lsp-bridge>
- Emacs Wiki: <https://www.emacswiki.org/emacs/SiteMap>
- Awesome Emacs: <https://github.com/emacs-tw/awesome-emacs#lsp-client>
- Chinese(rime) support: <https://github.com/DogLooksGood/emacs-rime>
- modal editing:
  - <https://github.com/emacs-evil/evil>: evil mode, enabled by default in doom-emacs.
  - <https://github.com/meow-edit/meow>

## Install or Update

After deploying this nix flake, run the following command to install or update emacs:

```bash
doom sync
```

when in doubt, run `doom sync`!

## Testing

> via `Justfile` located at the root of this repo.

```bash
# testing
just emacs-test
just emacs-purge
just emacs-reload

# clear test data
just emacs-clean
```

## Limits

- It's too slow to start up and install(compile/build) packages.
  - I have to use emacs in daemon/client mode to avoid this issue.
- It's too large in size, not suitable for servers.
  - So vim/neovim is still the best choice for servers.
- Emacs's markdown-mode works not well with tables, see:
  - https://github.com/jrblevin/markdown-mode/issues/380
- I use git command frequently, but doomemacs only autoupdates status of git diff / treemacs when
  using magit.
  - I have to learn magit to avoid this issue...
- GitHub's orgmode support is not well, Markdown is better for GitHub.
  - Use markdown for repo's README.md, and use orgmode for my personal notes and docs only.

## Cheetsheet

Here is the cheetsheet related to my DoomEmacs configs. Please read vim's common cheetsheet at
[../README.md](../README.md) before reading the following.

### Basics

> Terminal(vterm) is useful in GUI mode, I use Zellij instead in terminal mode.

| Action                 | Shortcut                                          |
| ---------------------- | ------------------------------------------------- |
| Popup Terminal(vterm)  | `SPC + o + t`                                     |
| Open Terminal          | `SPC + o + T`                                     |
| Open file tree sidebar | `SPC + o + p`                                     |
| Frame fullscreen       | `SPC + t + F`                                     |
| Exit                   | `M-x C-c`                                         |
| Execute Command        | `M-x`(hold on `Alt`/`option`, and then press `x`) |
| Eval Lisp Code         | `M-:`(hold on `Alt`/`option`, and then press `:`) |

### Window Navigation

| Action                                     | Shortcut                                                              |
| ------------------------------------------ | --------------------------------------------------------------------- |
| Split a window vertically and horizontally | `SPC w v/s`                                                           |
| Move to a window in a specific direction   | `Ctrl-w + h/j/k/l`                                                    |
| Move a window to a specific direction      | `Ctrl-w + H/J/K/L`                                                    |
| Move to the next window                    | `SPC w w`                                                             |
| Close the current window                   | `SPC w q`                                                             |
| Rebalance all windows                      | `SPC w =`                                                             |
| Set window's width(columns)                | `80 SPC w \|` (the Vertical line is escaped due to markdown's limits) |
| Set window's height                        | `30 SPC w _ `                                                         |

### File Tree

- treemacs: <https://github.com/Alexander-Miller/treemacs/blob/master/src/elisp/treemacs-mode.el>
- treemacs-evil:
  <https://github.com/Alexander-Miller/treemacs/blob/master/src/extra/treemacs-evil.el>

| Action                                | Shortcut  |
| ------------------------------------- | --------- |
| Resize Treemacs's window              | `>` & `<` |
| Extra Wide Window                     | `W`       |
| Rename                                | `R`       |
| Delete File/Direcoty                  | `d`       |
| New File                              | `cf`      |
| New Directory                         | `cd`      |
| Go to parent                          | `u`       |
| Run shell command in for current node | `!`       |
| Refresh file tree                     | `gr`      |
| Copy project-path into pasteboard     | `yp`      |
| Copy absolute-path into pasteboard    | `ya`      |
| Copy relative-path into pasteboard    | `yr`      |
| Copy file to another location         | `yf`      |
| Move file to another location         | `m`       |
| quit                                  | `q`       |

And bookmarks:

- Add bookmarks in treemacs: `b`
- Show Bookmark List: `SPC s m`

### Splitting and Buffers

| Action                  | Shortcut          |
| ----------------------- | ----------------- |
| Buffer List             | `<Space> + ,`     |
| Save all buffers(Tab)   | `<Space> + b + S` |
| Kill the current buffer | `<Space> + b + k` |
| Kill all buffers        | `<Space> + b + K` |

### Editing and Formatting

| Action                                     | Shortcut            |
| ------------------------------------------ | ------------------- |
| Format Document                            | `<Space> + cf`      |
| Code Actions                               | `<Space> + ca`      |
| Rename                                     | `<Space> + cr`      |
| Opening LSP symbols                        | `<Space> + cS`      |
| Show all LSP Errors                        | `<Space> + c + x/X` |
| Show infinite undo history(really useful!) | `<Space> + s + u`   |
| Open filepath/URL at cursor                | `gf`                |
| Find files by keyword in path              | `<Space> + <Space>` |
| Grep string in files (vertico + ripgrep)   | `<Space> + sd`      |

### Image Preview(GUI mode only)

Use `-`, `+` to resize the image, `r` to rotate the image.

### Search & replace

```bash
SPC s p foo C-; E C-c C-p :%s/foo/bar/g RET Z Z
```

1. `SPC s p`: search in project
1. `foo`: the keyword to search
1. `C-; E`: exports what you’re looking at into a new buffer in grep-mode
1. `C-c C-p` to run wgrep-change-to-wgrep-mode to make the search results writable.
1. `:%s/foo/bar/g RET`: replace in the current buffer(just like neovim/vim)
1. `Z Z`: to write all the changes to their respective files

### Projects

> easily switch between projects without exit emacs!

| Action                     | Shortcut      |
| -------------------------- | ------------- |
| Switch between projects    | `SPC + p + p` |
| Browse the current project | `SPC + p + .` |
| Add new project            | `SPC + p + a` |

### Workspaces

> Very useful when run emacs in daemon/client modes

| Action                      | Shortcut                    |
| --------------------------- | --------------------------- |
| Switch between workspaces   | `M-1/2/3/...`(Alt-1/2/3/..) |
| New Workspace               | `SPC + TAB + n`             |
| New Named Workspace         | `SPC + TAB + N`             |
| Delete Workspace            | `SPC + TAB + d`             |
| Display Workspaces bar blow | `SPC + TAB + TAB`           |

### Magit

> https://github.com/magit/magit

Magit is a powerful tool that make git operations easy and intuitive.

| Action                   | Shortcut                 |
| ------------------------ | ------------------------ |
| Open Magit               | `C-x g` or `SPC + g + g` |
| Switch branch            | `SPC + g + b`            |
| Show buffer's commit log | `SPC + g + L`            |

Shortcuts in magit's pane:

> When run `git commit` / `git add` / `git push` /... via magit, multiple Arguments can be set. Set
> arguments won't trigger a git command immediately. Magit will try to run a git command only after
> an Action key is pressed.

| Action                                             | Shortcut                                      |
| -------------------------------------------------- | --------------------------------------------- |
| Quit the current Magit pane                        | `q`                                           |
| Show log                                           | `l`                                           |
| Show current branch's log                          | `l + l`                                       |
| Show current reflog                                | `l + r`                                       |
| Commit                                             | `c`                                           |
| Stage                                              | `s`                                           |
| Unstage                                            | `u`                                           |
| Push                                               | `p`                                           |
| Pull                                               | `f`                                           |
| Rebase                                             | `r`                                           |
| Rebase Interactively                               | `r + i`, select on a commit, then `C-c + C-c` |
| Stash                                              | `z`                                           |
| Merge                                              | `m`                                           |
| Fold/Unfold                                        | `TAB`                                         |
| Show details of the current unit(commit/stage/...) | `<ENTER>`                                     |

KeyBinding full list:
<https://github.com/emacs-evil/evil-collection/tree/master/modes/magit#key-bindings>
