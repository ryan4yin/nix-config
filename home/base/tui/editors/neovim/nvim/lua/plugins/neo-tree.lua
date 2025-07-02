-- File explorer(Custom configs)
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {
      visible = true, -- visible by default
      hide_dotfiles = false,
      hide_gitignored = false,
    }
    opts.filesystem.follow_current_file = {
      enabled = true, -- This will find and focus the file in the active buffer every time
      leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    }
  end,
}
