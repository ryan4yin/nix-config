# Helix Editor

Neovim is really powerful, and have a very active community. I use it as my main editor, and I'm
very happy with it. I use it for everything, from writing code to writing this document.

But its configuration is a bit complex, and finding the right plugins, writing configurations, and
keeping everything up to date is not easy.

That's why I'm interested in Helix, Helix is similar to Neovim, but it's more opinionated, and it's
batteries included. Whether I'll switch my main editor to Helix or not, it gives me a lot of ideas
on how to improve my Neovim workflow.

## Tutorial

Use `:tutor` in helix to start the tutorial.

## Differences between Neovim and Helixer

1. Selecting first, then action.
   1. Helix: delete 2 word: `2w` then `x`. You can always see what you're selecting before you apply
      the action.
   2. Neovim: delete 2 word: `d`. then `2w`. No visual feedback before you apply the action.
1. Helix - Morden builtin features: LSP, tree-sitter, fuzzy finder, multi cursors, surround and
   more.
   1. They're all available in Neovim too, but you need to find and use the right plugins manually,
      which takes time and effort.
1. Helix is built in Rust from scratch. The result is a much smaller codebase and a modern set of
   defaults. No VimScript. No Lua.
   1. Neovim contains a lot of VimScript, and lua is too dynamic, it's hard to debug.
   1. Personally I'm glad to take a look at a Rust codebase, but not a VimScript/Lua codebase.
1. Neovim have a very activate plugin ecosystem, and it's easy to find plugins for almost
   everything.
   1. Helix is still new, and it even do have a stable plugin system yet. A PR to add a plugin
      system is still envolving: <https://github.com/helix-editor/helix/pull/8675>
1. Neovim has integrated terminal, and it's very powerful. It's quite similar to VSCode's integrated
   terminal. I use it a lot.
   1. Helix doesn't have a integrated terminal yet, as it's complicated to implement. Users are
      recommended to use tmux/Zellij or Wezterm/Kitty to implement this feature instead.
   1. <https://github.com/helix-editor/helix/issues/1976#issuecomment-1091074719>
   1. <https://github.com/helix-editor/helix/pull/4649>
   1. **My Neovim often gets stuck when I switch to
      [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim), this Helix issue made me
      consider to switch from this Neovim plugin to Zellij**.
1. Helix do not have a tree-view panel, it's recommended to use Yazi/ranger/Broot instead, and open
   Helix in them.
   1. a tree-view plugin may be added after the plugin system is stable, but no one knows when it
      will be.
   2. and some Helix users stated that they don't need a tree-view plugin, Helix's file picker is
      useful and good enough.
1. It seems Helix lacks a global substitution command, you should run it in another window(via wm or
   Zellij).
   1. <https://github.com/helix-editor/helix/issues/196>
   1. Neovim's substitution command allow you to preview the changes before you apply it, and it's
      very useful. if I switch to Helix, I'll need to find some other tools with similar
      feature(such as https://github.com/ms-jpq/sad).
1. Complexity and Maintenance Costs vs Batteries Included:
   <https://github.com/helix-editor/helix/discussions/6356>

I think Use Helix/Neovim within a terminal file manager(Yazi/ranger/Broot) and Zellij is a good
idea. It's quite different from the workflow I migrated from VSCode/JetBrains before, I'm very
interested in it.

In Neovim I can make the workflow similar to VSCode/JetBrains by using some plugins, but Helix
forces me to get out of my comfort zone, and try something new.
