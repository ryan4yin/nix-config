-- markdown preview
return {
  "0x00-ketsu/markdown-preview.nvim",
  ft = { "md", "markdown", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd", "wiki" },
  config = function()
    require("markdown-preview").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the setup section below
    }
  end,
}
