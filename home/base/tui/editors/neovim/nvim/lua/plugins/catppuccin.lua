return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = function(_, opts)
    opts.flavour = "mocha" -- latte, frappe, macchiato, mocha
    opts.transparent_background = true -- setting the background color.
  end,
}
