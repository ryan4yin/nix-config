return {
	"kylechui/nvim-surround",
	event = "BufReadPost",
	config = function()
		require("nvim-surround").setup()
	end,
}
