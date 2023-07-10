return {
	"leoluz/nvim-dap-go",
	ft = { "go" },
	config = function()
		require("dap-go").setup()
	end,
}
