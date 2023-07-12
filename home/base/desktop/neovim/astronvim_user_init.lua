return {
  colorscheme = "catppuccin",

  options = {
    opt = {
      cmdheight = 0, -- Do not display cmd line(use noice.nvim instead)
      relativenumber = true, -- Show relative numberline
      signcolumn = "auto", -- Show sign column when used only
      spell = true, -- Enable spell checking
    },
  },

  plugins = {
    "AstroNvim/astrocommunity",
    -- colorscheme - catppuccin
    { import = "astrocommunity.colorscheme.catppuccin" },
    -- Highly experimental plugin that completely replaces
    -- the UI for messages, cmdline and the popupmenu.
    { import = "astrocommunity.utility.noice-nvim" },
    -- Fully featured & enhanced replacement for copilot.vim
    -- <Tab> work with both auto completion in cmp and copilot
    { import = "astrocommunity.completion.copilot-lua" },
    {
      "jay-babu/mason-nvim-dap.nvim",
      config = function()
        local dap = require('dap')
        local adapters = require('mason-nvim-dap.mappings.adapters')
        local configurations = require('mason-nvim-dap.mappings.configurations')

        dap.adapters.delve = adapters.delve
        dap.configurations.go = configurations.delve
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
          },
        },
      }
    },
    {
      "jose-elias-alvarez/null-ls.nvim",
      opts = function(_, opts)
        local null_ls = require "null-ls"
        -- Include code and source with diagnostics message
        opts.diagnostics_format = "[#{c}] #{m} (#{s})"
        opts.sources = {
          null_ls.builtins.diagnostics.golangci_lint,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.ruff,
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.gofumpt.with({
            extra_args = { "-extra" },
          }),
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.ruff,
          null_ls.builtins.formatting.shfmt.with({
            extra_args = { "-i", "2", "-ci", "-bn"},
          }),
        }
        return opts
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = {
          "bash",
          "go",
          "gomod",
          "hcl",
          "jsonnet",
          "nix",
          "python",
          "regex",
          "rust",
          "terraform",
          "typescript",
        },
      },
    },
  },

  lsp = {
    servers = {
      "bashls",
      "clangd",   -- c/c++ language server
      "cmake",
      "cssls",
      "eslint",
      "gopls",
      "html",
      "jsonls",
      "jsonnet_ls",
      "lua_ls",
      "pyright",
      "nil_ls",  -- nix language server
      "rust_analyzer",
      "sqlls",   -- sql language server
      "terraformls",
      "tsserver",
      "yamlls",
    },
    formatting = {
      disabled = {
        -- use null-ls' gofumpt/goimports instead
        -- https://github.com/golang/tools/pull/410
        "gopls",
        -- use null-ls' prettier instead
        "tsserver",
      },
      format_on_save = {
        enabled = true,
        allow_filetypes = {
          "go",
          "jsonnet",
          "rust",
          "terraform",
        },
      },
    },
  },
}
