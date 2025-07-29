-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          "go",
          "jsonnet",
          "rust",
          "terraform",
          "nu",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    servers = {
      ---- Data & Configuration Languages
      "jsonls", -- json language server
      "jsonnet_ls", -- jsonnet language server
      "yamlls", -- yaml language server
      "taplo", -- toml language server
      "dagger", -- cuelsp - cue language server
      "terraformls", -- terraform hcl
      "marksman", -- markdown ls
      "nickel_ls", -- nickel language server
      -- "nil_ls", -- nix language server
      "nixd", -- another nix language server
      "buf_ls", -- protocol buffer language server
      "dockerls", -- dockerfile
      "cmake", -- cmake language server
      "sqls", -- sql language server

      ---- General Purpose Languages
      "clangd", -- c/c++
      "gopls", -- go
      "jdtls", -- java language server, provides only basic features
      "rust_analyzer", -- rust
      "pyright", -- python
      "ruff", -- extremely fast Python linter and code transformation
      -- "julials", -- julia language server
      -- "zls", -- zig language server
      "lua_ls", -- lua
      "bashls", -- bash
      "nushell", -- nushell language server

      ---- Web Development
      "ts_ls", -- typescript/javascript language server
      "tailwindcss", -- tailwindcss language server
      "html", -- html language server
      "cssls", -- css language server
      "prismals", -- prisma language server
      "volar", -- vue language server

      ---- Lisp Like
      "scheme_langserver", -- scheme language server
      "elixirls", -- elixir language server
      -- "clojure_lsp", -- clojure language server"

      ---- Circuit Design
      "verible", -- verilog language server
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- the offset_encoding of clangd will confilicts whit null-ls
      -- so we need to manually set it to utf-8
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
      },
      scheme_langserver = {
        filetypes = { "scheme", "scm" },
        single_file_support = true,
      },
      rust_analyzer = {
        settings = {
          -- Make the rust-analyzer use its own profile,
          -- so you can run cargo build without that being blocked while rust-analyzer runs.
          ["rust-analyzer"] = {
            cargo = {
              extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
              extraArgs = { "--profile", "rust-analyzer" },
            },
          },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_document_highlight = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/documentHighlight",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "CursorHold", "CursorHoldI" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Document Highlighting",
          callback = function() vim.lsp.buf.document_highlight() end,
        },
        {
          event = { "CursorMoved", "CursorMovedI", "BufLeave" },
          desc = "Document Highlighting Clear",
          callback = function() vim.lsp.buf.clear_references() end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gl = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },

        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        -- gD = {
        --   function() vim.lsp.buf.declaration() end,
        --   desc = "Declaration of current symbol",
        --   cond = "textDocument/declaration",
        -- },
        -- ["<Leader>uY"] = {
        --   function() require("astrolsp.toggles").buffer_semantic_tokens() end,
        --   desc = "Toggle LSP semantic highlight (buffer)",
        --   cond = function(client) return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens end,
        -- },

        -- refactoring
        ["<Leader>ri"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inverse of extract variable",
        },
        ["<Leader>rb"] = { function() require("refactoring").refactor "Extract Block" end, desc = "Extract Block" },
        ["<Leader>rbf"] = {
          function() require("refactoring").refactor "Extract Block To File" end,
          desc = "Extract Block To File",
        },
        ["<Leader>rr"] = {
          function() require("telescope").extensions.refactoring.refactors() end,
          desc = "Prompt for a refactor to apply",
        },
        ["<Leader>rp"] = {
          function() require("refactoring").debug.printf { below = false } end,
          desc = "Insert print statement to mark the calling of a function",
        },
        ["<Leader>rv"] = {
          function() require("refactoring").debug.print_var() end,
          desc = "Insert print statement to print a variable",
        },
        ["<Leader>rc"] = {
          function() require("refactoring").debug.cleanup {} end,
          desc = "Cleanup of all generated print statements",
        },
      },
      -- visual mode(what's the difference between v and x???)
      x = {
        -- refactoring
        ["<Leader>ri"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inverse of extract variable",
        },
        ["<Leader>re"] = {
          function() require("refactoring").refactor "Extract Function" end,
          desc = "Extracts the selected code to a separate function",
        },
        ["<Leader>rf"] = {
          function() require("refactoring").refactor "Extract Function To File" end,
          desc = "Extract Function To File",
        },
        ["<Leader>rv"] = {
          function() require("refactoring").refactor "Extract Variable" end,
          desc = "Extracts occurrences of a selected expression to its own variable",
        },
        ["<Leader>rr"] = {
          function() require("telescope").extensions.refactoring.refactors() end,
          desc = "Prompt for a refactor to apply",
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
