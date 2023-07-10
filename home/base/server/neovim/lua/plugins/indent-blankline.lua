return {
	"lukas-reineke/indent-blankline.nvim",
	config = function()
		vim.opt.list = true
		vim.opt.listchars:append("space:⋅")
		vim.opt.listchars:append("eol:↴")

		require("indent_blankline").setup({
			char = "▏",
			show_end_of_line = true,
			space_char_blankline = " ",
			show_current_context = true,
			show_current_context_start = true,
		})
	end,
}
