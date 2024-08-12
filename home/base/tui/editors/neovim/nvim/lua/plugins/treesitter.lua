-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    -- NOTE: additional parser
    { "nushell/tree-sitter-nu" }, -- nushell scripts
  },
  opts = function(_, opts)
    opts.incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>", -- Ctrl + Space
        node_incremental = "<C-space>",
        scope_incremental = "<A-space>", -- Alt + Space
        node_decremental = "<bs>", -- Backspace
      },
    }
    opts.ignore_install = { "gotmpl", "wing" }

    -- add more things to the ensure_installed table protecting against community packs modifying it
    -- https://github.com/nvim-treesitter/nvim-treesitter/tree/master
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      -- please add only the tree-sitters that are not available in nixpkgs here

      "just",
      "kdl",
      "csv",
      "xml",

      ---- Misc
      "diff",
      "git_config",
      "git_rebase",
      "gitignore",
      "gitcommit",
      "gitattributes",
      "ssh_config",
    })
  end,
}
