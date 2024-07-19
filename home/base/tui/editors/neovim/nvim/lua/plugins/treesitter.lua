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
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      -- neovim
      "vim",
      "lua",
      -- operation & cloud native
      "dockerfile",
      "hcl",
      "jsonnet",
      "regex",
      "terraform",
      "nix",
      "csv",
      "nickel", -- nickel language
      "just", -- justfile
      -- other programming language
      "diff",
      "gitignore",
      "gitcommit",
      "latex",
      "sql",
      -- Lisp like
      "fennel",
      "clojure",
      "commonlisp",
      "scheme",
    })
  end,
}
