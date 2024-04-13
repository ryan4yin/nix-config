return {
  "0x00-ketsu/autosave.nvim",
  -- lazy-loading on events
  event = { "InsertLeave", "TextChanged" },
  opts = function(_, opts)
    opts.prompt_style = "stdout" -- notify or stdout
  end,
}
