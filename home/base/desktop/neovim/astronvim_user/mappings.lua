-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
local utils = require "astronvim.utils"

require("telescope").load_extension("refactoring")
require("telescope").load_extension("yank_history")
require("telescope").load_extension("undo")

return {
  -- normal mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    -- quick save
    ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    ["<leader>tp"] = { function() utils.toggle_term_cmd("ipython") end, desc = "ToggleTerm python" },

    -- search and replace globally
    ['<leader>ss'] = {'<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
    ['<leader>sw'] = {'<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "Search current word" },
    ['<leader>sp'] ={'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', desc = "Search on current file" },

    -- refactoring
    ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Inverse of extract variable" },
    ["<leader>rb"] = { function() require('refactoring').refactor('Extract Block') end, desc = "Extract Block" },
    ["<leader>rbf"] = { function() require('refactoring').refactor('Extract Block To File') end, desc = "Extract Block To File" },
    ["<leader>rr"] = { function() require('telescope').extensions.refactoring.refactors() end, desc = "Prompt for a refactor to apply" },
    ["<leader>rp"] = { function() require('refactoring').debug.printf({below = false}) end, desc = "Insert print statement to mark the calling of a function" },
    ["<leader>rv"] = { function() require('refactoring').debug.print_var() end, desc = "Insert print statement to print a variable" },
    ["<leader>rc"] = { function() require('refactoring').debug.cleanup({}) end, desc = "Cleanup of all generated print statements" },

    -- yank_history
    ["<leader>yh"] = { function() require("telescope").extensions.yank_history.yank_history() end, desc = "Preview Yank History" },

    -- undo history
    ["<leader>uh"] = {"<cmd>Telescope undo<cr>", desc="Telescope undo" },

    -- implementation/definition preview
    ["gpd"] = { "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc="goto_preview_definition" },
    ["gpt"] = { "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc="goto_preview_type_definition" },
    ["gpi"] = { "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc="goto_preview_implementation" },
    ["gP" ] = {  "<cmd>lua require('goto-preview').close_all_win()<CR>", desc="close_all_win" },
    ["gpr"] = { "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc="goto_preview_references" },
  },
  -- Visual mode
  v = {
    -- search and replace globally
    ['<leader>sw'] =  {'<esc><cmd>lua require("spectre").open_visual()<CR>', desc = "Search current word" },
  },
  -- visual mode(what's the difference between v and x???)
  x = {
    -- refactoring
    ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Inverse of extract variable" },
    ["<leader>re"] = { function() require('refactoring').refactor('Extract Function') end, desc = "Extracts the selected code to a separate function" },
    ["<leader>rf"] = { function() require('refactoring').refactor('Extract Function To File') end, desc = "Extract Function To File" },
    ["<leader>rv"] = { function() require('refactoring').refactor('Extract Variable') end, desc = "Extracts occurrences of a selected expression to its own variable" },
    ["<leader>rr"] = { function() require('telescope').extensions.refactoring.refactors() end, desc = "Prompt for a refactor to apply" },
  },
}
