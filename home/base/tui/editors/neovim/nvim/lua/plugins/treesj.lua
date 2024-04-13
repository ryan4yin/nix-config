-- joining blocks of code into oneline, or splitting one line into multiple lines.
return {
  "Wansmer/treesj",
  keys = { "<space>m", "<space>j", "<space>s" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("treesj").setup { --[[ your config ]]
    }
  end,
}
