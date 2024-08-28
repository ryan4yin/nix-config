# Neovim Editor

My Neovim config based on [AstroNvim](https://github.com/AstroNvim/AstroNvim). For more details,
visit the [AstroNvim website](https://astronvim.com/).

This document outlines neovim's configuration structure and various shortcuts/commands for efficient
usage.

## Screenshots

![](/_img/astronvim_2023-07-13_00-39.webp) ![](/_img/hyprland_2023-07-29_2.webp)

## Configuration Structure

| Description                                       | Standard Location                           | My Location                                                               |
| ------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------- |
| Neovim's config                                   | `~/.config/nvim`                            | AstroNvim's github repository, referenced as a flake input in this flake. |
| AstroNvim's user configuration                    | `$XDG_CONFIG_HOME/astronvim/lua/user`       | [./astronvim_user/](./astronvim_user/)                                    |
| Plugins installation directory (lazy.nvim)        | `~/.local/share/nvim/`                      | The same as standard location, generated and managed by lazy.nvim.        |
| LSP servers, DAP servers, linters, and formatters | `~/.local/share/nvim/mason/`(by mason.nvim) | [./default.nix](./default.nix), installed by nix.                         |

## Update/Clean Plugins

Note that lazy.nvim will not automatically update plugins, so you need to update them manually.

```bash
:Lazy update
```

Remove all unused plugins:

```bash
:Lazy clean
```

## Testing

> via `Justfile` located at the root of this repo.

```bash
# testing
just nvim-test

# clear test data
just nvim-clear
```

## Cheetsheet

Here is the cheetsheet related to my Neovim configs. Please read vim's common cheetsheet at
[../README.md](../README.md) before reading the following.

### Incremental Selection

Provided by nvim-treesitter.

| Action            | Shortcut       |
| ----------------- | -------------- |
| init selection    | `<Ctrl-space>` |
| node incremental  | `<Ctrl-space>` |
| scope incremental | `<Alt-Space>`  |
| node decremental  | `Backspace`    |

### Search and Jump

Provided by [flash.nvim](https://github.com/folke/flash.nvim), it's a intelligent search and jump
plugin.

1. It enhances the default search and jump behavior of neovim.(search with prefix `/`)

| Action            | Shortcut                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------ |
| Search            | `/`(normal search), `s`(disable all code highlight, only highlight matches)                                  |
| Treesitter Search | `yR`,`dR`, `cR`, `vR`, `ctrl+v+R`(around your matches, all the surrounding Treesitter nodes will be labeled) |
| Remote Flash      | `yr`, `dr`, `cr`, (around your matches, all the surrounding Treesitter nodes will be labeled)                |

### Commands & Shortcuts

| Action                        | Shortcut       |
| ----------------------------- | -------------- |
| Open file explorer            | `<Space> + e`  |
| Focus Neotree to current file | `<Space> + o`  |
| Toggle line wrap              | `<Space> + uw` |
| Show line diagnostics         | `gl`           |
| Show function/variable info   | `K`            |
| References of a symbol        | `gr`           |
| Next tab                      | `]b`           |
| Previous tab                  | `[b`           |

### Window Navigation

- Switch between windows: `<Ctrl> + h/j/k/l`
- Resize windows: `<Ctrl> + Up/Down/Left/Right` (`<Ctrl-w> + -/+/</>`)
  - Note: On macOS, conflicts with system shortcuts
  - Disable in System Preferences -> Keyboard -> Shortcuts -> Mission Control

### Splitting and Buffers

| Action           | Shortcut      |
| ---------------- | ------------- |
| Horizontal Split | `\`           |
| Vertical Split   | `\|`          |
| Close Buffer     | `<Space> + c` |

### Editing and Formatting

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
| Find files by name (include hidden files)             | `<Space> + fF` |
| Grep string in files (ripgrep)                        | `<Space> + fw` |
| Grep string in files (include hidden files)           | `<Space> + fW` |

### Git

| Action                     | Shortcut        |
| -------------------------- | --------------- |
| Git Commits (repository)   | `:<Space> + gc` |
| Git Commits (current file) | `:<Space> + gC` |
| Git Branches               | `:<Space> + gb` |
| Git Status                 | `:<Space> + gt` |

### Sessions

| Action                         | Shortcut       |
| ------------------------------ | -------------- |
| Save Session                   | `<Space> + Ss` |
| Last Session                   | `<Space> + Sl` |
| Delete Session                 | `<Space> + Sd` |
| Search Session                 | `<Space> + Sf` |
| Load Current Directory Session | `<Space> + S.` |

### Debugging

Press `<Space> + D` to view available bindings and options.

### Search and Replace Globally

| Description                                | Shortcut       |
| ------------------------------------------ | -------------- |
| Open spectre.nvim search and replace panel | `<Space> + ss` |

Search and replace via cli(fd + sad + delta):

```bash
fd "\\.nix$" . | sad '<pattern>' '<replacement>' | delta
```

### Surrounding Characters

Provided by mini.surround plugin.

- Prefix `gz`

| Action                         | Shortcut | Description                                     |
| ------------------------------ | -------- | ----------------------------------------------- |
| Add surrounding characters     | `gzaiw'` | Add `'` around the word under cursor            |
| Delete surrounding characters  | `gzd'`   | Delete `'` around the word under cursor         |
| Replace surrounding characters | `gzr'"`  | Replace `'` by `"` around the word under cursor |
| Highlight surrounding          | `gzh'`   | Highlight `'` around the word under cursor      |

### Text Manipulation

| Action                                 |               |
| -------------------------------------- | ------------- |
| Join with LSP intelligence(treesj)     | `<Space> + j` |
| Split Line into Multiple Lines(treesj) | `<Space> + s` |

### Miscellaneous

| Action                            |                 |
| --------------------------------- | --------------- |
| Show all Yank History             | `:<Space> + yh` |
| Show undo history                 | `:<Space> + uh` |
| Show the path of the current file | `:!echo $%`     |

## Additional Resources

For more detailed information and advanced usage, refer to:

1. [AstroNvim walkthrough](https://astronvim.com/Basic%20Usage/walkthrough)
2. [./astronvim_user/mapping.lua](./astronvim_user/mappings.lua)
3. All the plugins' documentations
