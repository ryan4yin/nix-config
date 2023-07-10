return {
	"lukas-reineke/headlines.nvim",
	ft = { "norg", "markdown", "orgmode" },
	config = function()
		require("headlines").setup({
			markdown = {
				headline_highlights = {
					"Headline1",
					"Headline2",
					"Headline3",
					"Headline4",
					"Headline5",
					"Headline6",
				},
				codeblock_highlight = "CodeBlock",
				dash_highlight = "Dash",
				quote_highlight = "Quote",
			},
		})
	end,
}
