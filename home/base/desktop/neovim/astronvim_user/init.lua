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
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.yaml" },
    { import = "astrocommunity.pack.toml" },
    ---- Backend
    { import = "astrocommunity.pack.go" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.java" },
    { import = "astrocommunity.pack.nix" },
    { import = "astrocommunity.pack.proto" },
    { import = "astrocommunity.pack.terraform" },
    ---- Operation & Cloud Native
    { import = "astrocommunity.pack.bash" },
    { import = "astrocommunity.pack.cmake" },
    { import = "astrocommunity.pack.cpp" },
    { import = "astrocommunity.pack.docker" },
    { import = "astrocommunity.pack.lua" },

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
    -- Language Parser for syntax highlighting / indentation / folding / Incremental selection
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = {
          -- neovim
          "vim",
          "lua",
          -- operation & cloud native
          "dockerfile",
          "hcl",
          "jsonnet",
          "regex",
          "terraform",
        },
      },
    },

    -- Install lsp, formmatter and others via home manager instead of Mason.nvim
    -- LSP installations
    {
      "williamboman/mason-lspconfig.nvim",
      -- ensure_installed nothing
      opts = function(_, opts) opts.ensure_installed = {
        "emmet_ls", -- not exist in nixpkgs, so install it via mason
      } end,
    },
    -- Formatters/Linter installation
    {
      "jay-babu/mason-null-ls.nvim",
      -- ensure_installed nothing
      opts = function(_, opts) opts.ensure_installed = {} end,
    },
    -- Debugger installationl
    {
      "jay-babu/mason-nvim-dap.nvim",
      -- overrides `require("mason-nvim-dap").setup(...)`
      opts = function(_, opts) opts.ensure_installed = {} end,
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
      "dockerls",
      "jsonnet_ls",  -- jsonnet language server
      "terraformls",
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
