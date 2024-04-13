-- Custom copilot-lua to enable filetypes: markdown
return {
  "zbirenbaum/copilot.lua",
  opts = function(_, opts)
    opts.filetypes = {
      yaml = true,
      markdown = true,
    }
  end,
}
