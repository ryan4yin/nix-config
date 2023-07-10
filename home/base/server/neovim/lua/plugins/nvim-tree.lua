return {
	"kyazdani42/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "tt", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
	},
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
		vim.opt.termguicolors = true
		require("nvim-tree").setup({ -- BEGIN_DEFAULT_OPTS
			sort_by = "case_sensitive",
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = true,
			},
			view = {
				width = 25,
				--[[ height = 30, ]]
				side = "left",
				--[[ float = {
					enable = true,
					open_win_config = {
						relative = "editor",
						--border = "rounded",
						width = 65,
						height = 25,
						row = 6,
						col = 45,
					},
				}, ]]
			},
		})
	end,
}
