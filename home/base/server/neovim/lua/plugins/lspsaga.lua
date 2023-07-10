return {
	"glepnir/lspsaga.nvim",
	event = "BufRead",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local colors, kind
		if os.getenv("GTK_THEME") == "Catppuccin-Frappe-Pink" or os.getenv("GTK_THEME") == "Catppuccin-Latte-Green" then
			colors = require("catppuccin.groups.integrations.lsp_saga").custom_colors()
			kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind()
		else
			colors = { normal_bg = "#3b4252" }
		end
		require("lspsaga").setup({
			ui = {
				colors = colors,
				kind = kind,
				border = "single",
			},
			outline = {
				win_width = 25,
			},
		})
		--Switch theme again after lspsaga loaded from
		if os.getenv("GTK_THEME") == "Nordic" then
			vim.cmd([[ colorscheme nord ]])
		elseif os.getenv("GTK_THEME") == "Catppuccin-Frappe-Pink" then
			vim.cmd([[colorscheme catppuccin-frappe ]])
		else
			vim.cmd([[colorscheme catppuccin-latte ]])
		end

		local keymap = vim.keymap.set
		-- Lsp finder find the symbol definition implement reference
		-- if there is no implement it will hide
		-- when you use action in finder like open vsplit then you can
		-- use <C-t> to jump back
		keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")

		-- Code action
		keymap({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>")

		-- Rename
		keymap("n", "gr", "<cmd>Lspsaga rename<CR>")

		-- Rename word in whole project
		keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

		-- Peek Definition
		-- you can edit the definition file in this float window
		-- also support open/vsplit/etc operation check definition_action_keys
		-- support tagstack C-t jump back
		keymap("n", "gD", "<cmd>Lspsaga peek_definition<CR>")

		-- Go to Definition
		keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

		-- Show line diagnostics you can pass argument ++unfocus to make
		-- show_line_diagnostics float window unfocus
		keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

		-- Show cursor diagnostic
		-- also like show_line_diagnostics  support pass ++unfocus
		keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

		-- Show buffer diagnostic
		keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

		-- Diagnostic jump can use `<c-o>` to jump back
		keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
		keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

		-- Diagnostic jump with filter like Only jump to error
		keymap("n", "[E", function()
			require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
		end)
		keymap("n", "]E", function()
			require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
		end)

		-- Toggle Outline
		keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>")

		-- Hover Doc
		-- if there has no hover will have a notify no information available
		-- to disable it just Lspsaga hover_doc ++quiet
		-- press twice it will jump into hover window
		--[[ keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>") ]]
		-- if you want keep hover window in right top you can use ++keep arg
		-- notice if you use hover with ++keep you press this keymap it will
		-- close the hover window .if you want jump to hover window must use
		-- wincmd command <C-w>w
		keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

		-- Callhierarchy
		keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
		keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

		-- Float terminal
		keymap({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
	end,
}
