-- Custom copilot-lua to enable filetypes: markdown
return {
  -- "zbirenbaum/copilot.lua",

  -- Fix https://github.com/zbirenbaum/copilot.lua/pull/336
  "ryan4yin/copilot.lua",
  branch = "fix_issue_330",
  opts = function(_, opts)
    opts.filetypes = {
      yaml = true,
      markdown = true,
    }
  end,
}
