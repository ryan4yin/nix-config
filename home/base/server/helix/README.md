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

