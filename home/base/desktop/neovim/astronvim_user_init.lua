return {
  colorscheme = "catppuccin",

  options = {
    opt = {
      cmdheight = 1, -- Always display cmd line
      foldcolumn = "0", -- Hide foldcolumn
      guicursor = "", -- Disable Nvim GUI cursor
      mouse = "", -- Disable mouse support
      number = false, -- Hide numberline
      relativenumber = false, -- Hide relative numberline
      signcolumn = "auto", -- Show sign column when used only
      spell = true, -- Enable spell checking
    },
  },

  highlights = {
    -- Fix Gruvbox highlight groups
    -- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox/palette.lua
    gruvbox = {
      -- Hard-code reversed colors
      -- https://github.com/AstroNvim/AstroNvim/issues/1147
      StatusLine = { fg = "#ebdbb2", bg = "#504945" }, -- colors.light1 / colors.dark2
    },
  },

  plugins = {
    -- colorscheme - catppuccin
    {
      "catppuccin/nvim",
      name = "catppuccin",
      config = function()
        require("catppuccin").setup {}
      end,
    },

    -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu. 
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
        -- add any options here
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify",
        }
    },

    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require("astronvim.utils.status")
        opts.statusline = vim.tbl_deep_extend("force", opts.statusline, {
          -- add mode component
          status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
        })
        return opts
      end
    },
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
