return {
	"jose-elias-alvarez/null-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		require("null-ls").setup({
			sources = {
				-- you must download code formatter by yourself!
				require("null-ls").builtins.formatting.stylua,
				require("null-ls").builtins.formatting.black,
				require("null-ls").builtins.formatting.prettier,
				require("null-ls").builtins.formatting.gofmt,
				require("null-ls").builtins.formatting.nixpkgs_fmt,
				require("null-ls").builtins.formatting.beautysh,
				require("null-ls").builtins.formatting.rustfmt,
				require("null-ls").builtins.formatting.stylish_haskell,
			},
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})
				end
			end,
		})
	end,
}
