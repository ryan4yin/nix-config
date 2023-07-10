return {
	"neovim/nvim-lspconfig",
	config = function()
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
		---------------------
		-- setup languages --
		---------------------
		-- nix
		nvim_lsp.nixd.setup({
			on_attach = on_attach(),
			capabilities = capabilities,
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
		--Rust
		-- require("rust-tools").setup({
		-- 	server = {
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach(),
		-- 	},
		-- }) -- C
		nvim_lsp.clangd.setup({
			on_attach = on_attach(),
			capabilities = capabilities,
		})
		--Python
		nvim_lsp.pyright.setup({
			on_attach = on_attach(),
			capabilities = capabilities,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "workspace",
						useLibraryCodeForTypes = true,
						typeCheckingMode = "off",
					},
				},
			},
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

		nvim_lsp.zk.setup({
			on_attach = on_attach(),
			capabilities = capabilities,
			cmd = { "zk", "lsp" },
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

		--nvim_lsp.rnix.setup({
		--  on_attach = on_attach(),
		--  capabilities = capabilities,
		--})
		--nvim_lsp.nil_ls.setup({
		--  on_attach = on_attach(),
		--  settings = {
		--    ["nil"] = {
		--      nix = {
		--        flake = {
		--          autoArchive = true,
		--        },
		--      },
		--    },
		--  },
		--})
		nvim_lsp.hls.setup({})

		-- ebuild Syntastic(install dev-util/pkgcheck)
		vim.g.syntastic_ebuild_checkers = "pkgcheck"

		--[[ -- Global mappings.
		-- See `:help vim.diagnostic.*` for documentation on any of the below functions
		vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
		vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

		-- Use LspAttach autocommand to only map the following keys
		-- after the language server attaches to the current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Manual, triggered completion is provided by Nvim's builtin omnifunc. For autocompletion, a general purpose autocompletion plugin(.i.e nvim-cmp) is required
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<space>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
				vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<space>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end,
		}) ]]

		-- show diagnostics when InsertLeave
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "go", "rust", "nix", "c++" },
			callback = function(args)
				vim.api.nvim_create_autocmd("DiagnosticChanged", {
					buffer = args.buf,
					callback = function()
						vim.diagnostic.hide()
					end,
				})
				vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
					buffer = args.buf,
					callback = function()
						vim.diagnostic.show()
					end,
				})
			end,
		})
		-- 为特定语言开启 inlay_hint 功能
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "rust" },
			callback = function()
				vim.lsp.inlay_hint(0, true)
			end,
		})
	end,
}
