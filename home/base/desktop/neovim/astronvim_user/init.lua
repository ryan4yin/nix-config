return {
  colorscheme = "catppuccin",

  options = {
    opt = {
      relativenumber = true, -- Show relative numberline
      signcolumn = "auto", -- Show sign column when used only
      spell = false, -- Spell checking
      swapfile = false, -- Swapfile

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
    { import = "astrocommunity.completion.copilot-lua-cmp" },
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
    { import = "astrocommunity.pack.nix" },
    { import = "astrocommunity.pack.proto" },
    ---- Operation & Cloud Native
    { import = "astrocommunity.pack.terraform" },
    { import = "astrocommunity.pack.bash" },
    { import = "astrocommunity.pack.cmake" },
    { import = "astrocommunity.pack.cpp" },
    { import = "astrocommunity.pack.docker" },
    ---- Nushell
    {
      "LhKipp/nvim-nu",
      config = function()
        require'nu'.setup({
          use_lsp_features = true, -- requires https://github.com/jose-elias-alvarez/null-ls.nvim
          -- lsp_feature: all_cmd_names is the source for the cmd name completion.
          -- It can be
          --  * a string, which is interpreted as a shell command and the returned list is the source for completions (requires plenary.nvim)
          --  * a list, which is the direct source for completions (e.G. all_cmd_names = {"echo", "to csv", ...})
          --  * a function, returning a list of strings and the return value is used as the source for completions
          all_cmd_names = [[nu -c 'help commands | get name | str join "\n"']]
        })
      end,
      dependencies = {
        {"nvim-treesitter/nvim-treesitter"},
        { "jose-elias-alvarez/null-ls.nvim"},
      }
    },

    -- File explorer(Custom configs)
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
      "ThePrimeagen/refactoring.nvim",
      dependencies = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-treesitter/nvim-treesitter"}
      }
    },
    -- Language Parser for syntax highlighting / indentation / folding / Incremental selection
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        local utils = require "astronvim.utils";
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
        })
      end,
    },

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

            -- Completion
            completion.luasnip,

            -- Diagnostic
            diagnostics.actionlint,  -- GitHub Actions workflow syntax checking
            diagnostics.buf,         -- check text in current buffer
            diagnostics.checkmake,   -- check Makefiles

            -- Formatting
            formatting.prettier, -- js/ts/vue/css/html/json/... formatter
            diagnostics.hadolint, -- Dockerfile linter
            formatting.black,     -- Python formatter
            formatting.ruff,      -- extremely fast Python linter
            formatting.goimports,  -- Go formatter
            formatting.shfmt,     -- Shell formatter
            formatting.rustfmt,   -- Rust formatter
            formatting.taplo,   -- TOML formatter
            formatting.terraform_fmt, -- Terraform formatter
            formatting.stylua,    -- Lua formatter
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
      ---- Operation & Cloud Native
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
