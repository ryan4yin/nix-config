return {
	"iamcco/markdown-preview.nvim",
	keys = {
		{ "mp", "<cmd>MarkdownPreview<CR>", desc = "MarkdownPreview" },
	},
	build = "cd app && npm install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	ft = { "markdown" },
}
