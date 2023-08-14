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
    -- Motion
    { import = "astrocommunity.motion.mini-surround" },
    -- https://github.com/echasnovski/mini.ai
    { import = "astrocommunity.motion.mini-ai" },
    { import = "astrocommunity.motion.flash-nvim" },
    { "folke/flash.nvim", vscode = false },
    -- Lua implementation of CamelCaseMotion, with extra consideration of punctuation.
    { import = "astrocommunity.motion.nvim-spider" },
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

    -- markdown preview
    {
      '0x00-ketsu/markdown-preview.nvim',
      ft = {'md', 'markdown', 'mkd', 'mkdn', 'mdwn', 'mdown', 'mdtxt', 'mdtext', 'rmd', 'wiki'},
      config = function()
        require('markdown-preview').setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the setup section below
        }
      end,
    },

    -- clipboard manager
    {
      "gbprod/yanky.nvim",
      opts = function()
        local mapping = require "yanky.telescope.mapping"
        local mappings = mapping.get_defaults()
        mappings.i["<c-p>"] = nil
        return {
          highlight = { timer = 200 },
          picker = {
            telescope = {
              use_default_mappings = false,
              mappings = mappings,
            },
          },
        }
      end,
      keys = {
        { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
        { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
        { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
        { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
        { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
        { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
        { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
        { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
        { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
        { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
        { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
        { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
        { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
      },
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

    {
      'nvim-telescope/telescope.nvim', branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
      init = function()
        -- 1. Disable highlighting for certain filetypes
        -- 2. Ignore files larger than a certain filesize
        local previewers = require("telescope.previewers")

        local _bad = { ".*%.csv", ".*%.min.js" } -- Put all filetypes that slow you down in this array
        local filesize_threshold = 300 * 1024 -- 300KB
        local bad_files = function(filepath)
          for _, v in ipairs(_bad) do
            if filepath:match(v) then
              return false
            end
          end
          return true
        end

        local new_maker = function(filepath, bufnr, opts)
          opts = opts or {}
          if opts.use_ft_detect == nil then opts.use_ft_detect = true end

          -- 1. Check if the file is in the bad_files array, and if so, don't highlight it
          opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)

          -- 2. Check the file size, and ignore it if it's too big(preview nothing).
          filepath = vim.fn.expand(filepath)
          vim.loop.fs_stat(filepath, function(_, stat)
            if not stat then return end
            if stat.size > filesize_threshold then
              return
            else
              previewers.buffer_previewer_maker(filepath, bufnr, opts)
            end
          end)
        end

        require("telescope").setup {
          defaults = {
            buffer_previewer_maker = new_maker,
          }
        }
      end,
    }
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
