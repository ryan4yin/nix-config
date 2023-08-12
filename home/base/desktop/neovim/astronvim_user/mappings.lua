-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
local utils = require "astronvim.utils"
require("telescope").load_extension("refactoring")
return {
  -- first key is the mode
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
    ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Refactoring Inline Variable" },
    ["<leader>rb"] = { function() require('refactoring').refactor('Extract Block') end, desc = "Extract Block" },
    ["<leader>rbf"] = { function() require('refactoring').refactor('Extract Block To File') end, desc = "Extract Block To File" },
    ["<leader>rr"] = { function() require('telescope').extensions.refactoring.refactors() end, desc = "Prompt for a refactor to apply" },
    ["<leader>rp"] = { function() require('refactoring').debug.printf({below = false}) end, desc = "Print debug info" },
    ["<leader>rv"] = { function() require('refactoring').debug.print_var() end, desc = "Print debug var" },
    ["<leader>rc"] = { function() require('refactoring').debug.cleanup({}) end, desc = "Cleanup debugging" },
  },
  v = {
    -- search and replace globally
    ['<leader>sw'] =  {'<esc><cmd>lua require("spectre").open_visual()<CR>', desc = "Search current word" },
  },
  x = {
    -- refactoring
    ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Refactoring Inline Variable" },
    ["<leader>re"] = { function() require('refactoring').refactor('Extract Function') end, desc = "Extract Function" },
    ["<leader>rf"] = { function() require('refactoring').refactor('Extract Function To File') end, desc = "Extract Function To File" },
    ["<leader>rv"] = { function() require('refactoring').refactor('Extract Variable') end, desc = "Extract Variable" },
    ["<leader>rr"] = { function() require('telescope').extensions.refactoring.refactors() end, desc = "Prompt for a refactor to apply" },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
