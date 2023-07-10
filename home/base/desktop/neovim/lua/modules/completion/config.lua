local config = {}

-- config language servers in this function
-- https://github.com/williamboman/nvim-lsp-installer#available-lsps
function config.nvim_lsp()
  local nvim_lsp = require("lspconfig")

  -- Add additional capabilities supported by nvim-cmp
  -- nvim hasn't added foldingRange to default capabilities, users must add it manually
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  --Change diagnostic symbols in the sign column (gutter)
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
  })

  local on_attach = function(bufnr)
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "line",
        }
        vim.diagnostic.show()
        vim.diagnostic.open_float(nil, opts)
      end,
    })
  end

  -- nix
  -- nvim_lsp.nixd.setup({
  --   on_attach = on_attach(),
  --   capabilities = capabilities,
  -- })
  --nvim_lsp.rnix.setup({
  --  on_attach = on_attach(),
  --  capabilities = capabilities,
  --})
  nvim_lsp.nil_ls.setup({
   on_attach = on_attach(),
   settings = {
     ["nil"] = {
       nix = {
         flake = {
           autoArchive = true,
         },
       },
     },
   },
  })

  -- GoLang
  nvim_lsp["gopls"].setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
      },
    },
    init_options = {
      usePlaceholders = true,
    },
  })

  nvim_lsp.clangd.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
  })

  --Python
  nvim_lsp.pyright.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
  })

  --sumneko_lua
  nvim_lsp.lua_ls.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })

  nvim_lsp.rust_analyzer.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
  })
  nvim_lsp.html.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    cmd = { "vscode-html-language-server", "--stdio" },
  })

  nvim_lsp.cssls.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    cmd = { "vscode-css-language-server", "--stdio" },
  })

  nvim_lsp.tsserver.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    cmd = { "typescript-language-server", "--stdio" },
  })

  nvim_lsp.bashls.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    cmd = { "bash-language-server", "start" },
  })
end

function config.nvim_cmp()
  local cmp = require('cmp')

  local kind_icons = {
    Text = "󰊄",
    Method = "",
    Function = "󰡱",
    Constructor = "",
    Field = "",
    Variable = "󱀍",
    Class = "",
    Interface = "",
    Module = "󰕳",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  }
  -- find more here: https://www.nerdfonts.com/cheat-sheet

  cmp.setup({
    preselect = cmp.PreselectMode.Item,
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },

    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
        -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
        vim_item.menu = ({
          path = "[Path]",
          nvim_lua = "[NVIM_LUA]",
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = {
      { name = "path" },
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
    },
  })
end

function config.lua_snip()
  local ls = require('luasnip')
  local types = require('luasnip.util.types')
  ls.config.set_config({
    history = true,
    enable_autosnippets = true,
    updateevents = 'TextChanged,TextChangedI',
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { '<- choiceNode', 'Comment' } },
        },
      },
    },
  })
  require('luasnip.loaders.from_lua').lazy_load({ paths = vim.fn.stdpath('config') .. '/snippets' })
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = { './snippets/' },
  })
end

function config.lspsaga()
  require('lspsaga').setup({})
end
return config
