-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    -- NOTE: additional parser
    { "nushell/tree-sitter-nu" },
    { "IndianBoy42/tree-sitter-just" },
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
      -- customized languages:
      "scheme",
    })

    -- add support for scheme
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.scheme = {
      install_info = {
        url = "https://github.com/6cdh/tree-sitter-scheme", -- local path or git repo
        files = { "src/parser.c" },
        -- optional entries:
        branch = "main", -- default branch in case of git repo if different from master
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
        requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
      },
    }
    -- use scheme parser for filetypes: scm
    vim.treesitter.language.register("scheme", "scm")
  end,
}
