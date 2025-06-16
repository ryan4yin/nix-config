-- File explorer(Custom configs)
return {
  "nvim-neo-tree/neo-tree.nvim",
  -- Add shortcutes for avante.nvim
  config = function()
    require("neo-tree").setup {
      filesystem = {
        filtered_items = {
          visible = true, -- visible by default
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        commands = {
          avante_add_files = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative_path = require("avante.utils").relative_path(filepath)

            local sidebar = require("avante").get()

            local open = sidebar:is_open()
            -- ensure avante sidebar is open
            if not open then
              require("avante.api").ask()
              sidebar = require("avante").get()
            end

            sidebar.file_selector:add_selected_file(relative_path)

            -- remove neo tree buffer
            if not open then sidebar.file_selector:remove_selected_file "neo-tree filesystem [1]" end
          end,
        },
        window = {
          mappings = {
            ["oa"] = "avante_add_files",
          },
        },
      },
    }
  end,
}
