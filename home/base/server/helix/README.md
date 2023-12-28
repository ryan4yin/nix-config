# Helix Editor

Neovim is really powerful, and have a very active community. I use it as my main editor, and I'm very happy with it. I use it for everything, from writing code to writing this document.

But its configuration is a bit complex, and finding the right plugins, writing configurations, and keeping everything up to date is not easy.

That's why I'm interested in Helix, Helix is similar to Neovim, but it's more opinionated, and it's batteries included.
Whether I'll switch my main editor to Helix or not, it gives me a lot of ideas on how to improve my Neovim workflow.

## Differences between Neovim and Helixer

1. Neovim have a very activate plugin ecosystem, and it's easy to find plugins for almost everything.
    1. Helix is still new, and it even do have a stable plugin system yet. A PR to add a plugin system is still envolving: <https://github.com/helix-editor/helix/pull/8675>
2. Neovim has intergrated terminal, and it's very powerful. It's quite similar to VSCode's intergrated terminal. I use it a lot.
    1. Helix doesn't have a intergrated terminal yet, as it's complicated to implement. Users are recommended to use tmux/zellij or Wezterm/Kitty to implement this feature instead.
    1. <https://github.com/helix-editor/helix/issues/1976#issuecomment-1091074719>
    1. <https://github.com/helix-editor/helix/pull/4649>
    1. **My Neovim often gets stuck when I switch to [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim), this Helix issue made me consider to switch from this neovim plugin to zellij**.
1. Helix do not have a tree-view panel, it's recommended to use yazi/rangeer/broot instead, and open helix in them.
    1. a tree-view plugin may be added after the plugin system is stable, but no one knows when it will be.
    2. and some helix users stated that they don't need a tree-view plugin, helix's file picker is 
1. It seems Helix lacks a substitution command, you should run it in another window(via wm or zellij).
    1. Neovim's substitution command allow you to preview the changes before you apply it, and it's very useful. if I switch to Helix, I'll need to find some other tools with similar feature(such as https://github.com/ms-jpq/sad).
    2. The downside of Neovim's substitution command is that it's unable to save the command we just typed. If I made some things wrong, I have to type the whole substitution command again.

I think Use Helix/Neovim within a terminal file manager(zellij/ranger/broot) and zellij is a good idea. 
It's quite different from the workflow I migrated from VSCode/Jetbrains before, I'm very interested in it.

In Neovim I can make the workflow similar to VSCode/Jetbrains by using some plugins, but Helix forces me to get out of my comfort zone, and try something new.

