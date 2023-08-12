return {
  colorscheme = "catppuccin",

  options = {
    opt = {
      relativenumber = true, -- Show relative numberline
      signcolumn = "auto", -- Show sign column when used only
      spell = false, -- Spell checking
      swapfile = false, -- Swapfile
      smartindent = false; -- fix https://github.com/ryan4yin/nix-config/issues/4
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
    { import = "astrocommunity.media.vim-wakatime" },
    { import = "astrocommunity.motion.leap-nvim" },
    { import = "astrocommunity.motion.flit-nvim" },
    { import = "astrocommunity.scrolling.nvim-scrollbar" },
    { import = "astrocommunity.editing-support.auto-save-nvim" },
    { import = "astrocommunity.editing-support.todo-comments-nvim" },
    -- Language Support
    ---- Frontend & NodeJS
    { import = "astrocommunity.pack.typescript-all-in-one" },
    { import = "astrocommunity.pack.tailwindcss" },
    { import = "astrocommunity.pack.html-css" },
    { import = "astrocommunity.pack.prisma" },
    { import = "astrocommunity.pack.vue" },
    ---- Configuration Language
    { import = "astrocommunity.pack.markdown" },
    { import = "astrocommunity.markdown-and-latex.glow-nvim" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.yaml" },
    { import = "astrocommunity.pack.toml" },
    ---- Backend
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.go" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.java" },
    -- { import = "astrocommunity.pack.nix" },  -- manually add config for nix, comment this one.
    { import = "astrocommunity.pack.proto" },
    ---- Operation & Cloud Native
    { import = "astrocommunity.pack.terraform" },
    { import = "astrocommunity.pack.bash" },
    { import = "astrocommunity.pack.cmake" },
    { import = "astrocommunity.pack.cpp" },
    { import = "astrocommunity.pack.docker" },
    -- AI Assistant
    { import = "astrocommunity.completion.copilot-lua-cmp" },
    -- Custom copilot-lua to enable filtypes: markdown
    {
      "zbirenbaum/copilot.lua",
      opts = function(_, opts)
        opts.filetypes = {
          yaml = true;
          markdown = true,
        }
      end,
    },

    -- Enhanced matchparen.vim plugin for Neovim to highlight the outer pair.
    {
      "utilyre/sentiment.nvim",
      version = "*",
      event = "VeryLazy", -- keep for lazy loading
      opts = {
        -- config
      },
      init = function()
        -- `matchparen.vim` needs to be disabled manually in case of lazy loading
        vim.g.loaded_matchparen = 1
      end,
    },

    -- joining blocks of code into oneline, or splitting one line into multiple lines.
    {
      'Wansmer/treesj',
      keys = { '<space>m', '<space>j', '<space>s' },
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = function()
        require('treesj').setup({--[[ your config ]]})
      end,
    },

    -- clipboard history manager
    {
      "gbprod/yanky.nvim",
      config = function()
        require("yanky").setup({
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        })
      end,
    },

    -- File explorer(Custom configs)
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        filesystem = {
          filtered_items = {
            visible = true,   -- visible by default
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      }
    },
    -- The plugin offers the alibity to refactor code.
    {
      "ThePrimeagen/refactoring.nvim",
      dependencies = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-treesitter/nvim-treesitter"}
      }
    },
    -- The plugin offers the abilibty to search and replace.
    {
      "nvim-pack/nvim-spectre",
      dependencies = {
        {"nvim-lua/plenary.nvim"},
      }
    },

    -- full signature help, docs and completion for the nvim lua API.
    { "folke/neodev.nvim", opts = {} },

    { "RRethy/vim-illuminate", config = function() end },

    -- Language Parser for syntax highlighting / indentation / folding / Incremental selection
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        local utils = require "astronvim.utils";
        opts.incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",  -- Ctrl + Space
            node_incremental = "<C-space>",
            scope_incremental = "<A-space>",  -- Alt + Space
            node_decremental = "<bs>",  -- Backspace
          },
        }
        opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, {
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
        })
      end,
    },

    -- implementation/definition preview
    {
      'rmagatti/goto-preview',
      config = function()
        require('goto-preview').setup {}
      end
    },

    -- Undo tree
    { "debugloop/telescope-undo.nvim", },

    -- Lua implementation of CamelCaseMotion, with extra consideration of punctuation.
    { "chrisgrieser/nvim-spider", lazy = true },

    -- Install lsp, formmatter and others via home manager instead of Mason.nvim
    -- LSP installations
    {
      "williamboman/mason-lspconfig.nvim",
      -- overwrite ensure_installed to install lsp via home manager(except emmet_ls)
      opts = function(_, opts)
        opts.ensure_installed = {
          "emmet_ls", -- not exist in nixpkgs, so install it via mason
        }
      end,
    },
    -- Formatters/Linter installation
    {
      "jay-babu/mason-null-ls.nvim",
      -- ensure_installed nothing
      opts = function(_, opts)
        opts.ensure_installed = nil
        opts.automatic_installation = false
      end,
    },
    {
      "jose-elias-alvarez/null-ls.nvim",
      opts = function(_, opts)
        local null_ls = require "null-ls"
        local code_actions = null_ls.builtins.code_actions
        local diagnostics = null_ls.builtins.diagnostics
        local formatting = null_ls.builtins.formatting
        local hover = null_ls.builtins.hover
        local completion = null_ls.builtins.completion
        -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
        if type(opts.sources) == "table" then
          vim.list_extend(opts.sources, {
            -- Common Code Actions
            code_actions.gitsigns,
            -- common refactoring actions based off the Refactoring book by Martin Fowler
            code_actions.refactoring,
            code_actions.gomodifytags,  -- Go - modify struct field tags
            code_actions.impl,        -- Go - generate interface method stubs
            code_actions.shellcheck,
            code_actions.proselint,   -- English prose linter
            code_actions.statix,      -- Lints and suggestions for Nix.

            -- Completion
            completion.luasnip,

            -- Diagnostic
            diagnostics.actionlint,  -- GitHub Actions workflow syntax checking
            diagnostics.buf,         -- check text in current buffer
            diagnostics.checkmake,   -- check Makefiles
            diagnostics.deadnix,     -- Scan Nix files for dead code.

            -- Formatting
            formatting.prettier, -- js/ts/vue/css/html/json/... formatter
            diagnostics.hadolint, -- Dockerfile linter
            formatting.black,     -- Python formatter
            formatting.ruff,      -- extremely fast Python linter
            formatting.goimports,  -- Go formatter
            formatting.shfmt,     -- Shell formatter
            formatting.rustfmt,   -- Rust formatter
            formatting.taplo,   -- TOML formatteautoindentr
            formatting.terraform_fmt, -- Terraform formatter
            formatting.stylua,    -- Lua formatter
            formatting.alejandra, -- Nix formatter
            formatting.sqlfluff.with({  -- SQL formatter
              extra_args = { "--dialect", "postgres" }, -- change to your dialect
            }),
            formatting.nginx_beautifier,  -- Nginx formatter
          })
        end
      end,
    },
    -- Debugger installation 
    {
      "jay-babu/mason-nvim-dap.nvim",
      -- overrides `require("mason-nvim-dap").setup(...)`
      opts = function(_, opts)
        opts.ensure_installed = nil
        opts.automatic_installation = false
      end,
    },

    -- Fast and feature-rich surround actions
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { };
      },
    },
  },

  lsp = {
    config = {
      -- the offset_enconding of clangd will confilicts whit null-ls
      -- so we need to manually set it to utf-8
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
      },
    },
    -- enable servers that installed by home-manager instead of mason
    servers = {
      ---- Frontend & NodeJS
      "tsserver",     -- typescript/javascript language server
      "tailwindcss",  -- tailwindcss language server
      "html",         -- html language server
      "cssls",        -- css language server
      "prismals",     -- prisma language server
      "volar",        -- vue language server
      ---- Configuration Language
      "marksman",     -- markdown ls
      "jsonls",      -- json language server
      "yamlls",       -- yaml language server
      "taplo",         -- toml language server
      ---- Backend
      "lua_ls",         -- lua
      "gopls",          -- go
      "rust_analyzer",  -- rust
      "pyright",        -- python
      "ruff_lsp",       -- extremely fast Python linter and code transformation
      "jdtls",          -- java
      "nil_ls",         -- nix language server
      "bufls",          -- protocol buffer language server
      "zls",            -- zig language server
      ---- Operation & Cloud Nativautoindente
      "bashls",       -- bash
      "cmake",        -- cmake language server
      "clangd",       -- c/c++
      "dockerls",     -- dockerfile
      "jsonnet_ls",   -- jsonnet language server
      "terraformls",  -- terraform hcl
    },
    formatting = {
      disabled = {},
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
