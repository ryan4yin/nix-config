-- [nfnl] Compiled from mapping.fnl by https://github.com/Olical/nfnl, do not edit.
local utils = require "astronvim.utils"
do
end
(require "telescope").load_extension "refactoring"
do
end
(require "telescope").load_extension "yank_history"
do
end
(require "telescope").load_extension "undo"
local function _1_() return (require "refactoring").refactor "Extract Block" end
local function _2_() return (require "refactoring").refactor "Extract Block To File" end
local function _3_() return ((require "refactoring").debug).cleanup {} end
local function _4_() return (require "refactoring").refactor "Inline Variable" end
local function _5_() return ((require "refactoring").debug).printf { below = false } end
local function _6_() return (((require "telescope").extensions).refactoring).refactors() end
local function _7_() return ((require "refactoring").debug).print_var() end
local function _8_() return (((require "telescope").extensions).yank_history).yank_history() end
local function _9_() return (require "refactoring").refactor "Extract Function" end
local function _10_() return (require "refactoring").refactor "Extract Function To File" end
local function _11_() return (require "refactoring").refactor "Inline Variable" end
local function _12_() return (((require "telescope").extensions).refactoring).refactors() end
local function _13_() return (require "refactoring").refactor "Extract Variable" end
return {
  n = {
    ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>rb"] = { _1_, desc = "Extract Block" },
    ["<leader>rbf"] = { _2_, desc = "Extract Block To File" },
    ["<leader>rc"] = { _3_, desc = "Cleanup of all generated print statements" },
    ["<leader>ri"] = { _4_, desc = "Inverse of extract variable" },
    ["<leader>rp"] = { _5_, desc = "Insert print statement to mark the calling of a function" },
    ["<leader>rr"] = { _6_, desc = "Prompt for a refactor to apply" },
    ["<leader>rv"] = { _7_, desc = "Insert print statement to print a variable" },
    ["<leader>sp"] = {
      '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
      desc = "Search on current file",
    },
    ["<leader>ss"] = { '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
    ["<leader>sw"] = {
      '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
      desc = "Search current word",
    },
    ["<leader>uh"] = { "<cmd>Telescope undo<cr>", desc = "Telescope undo" },
    ["<leader>yh"] = { _8_, desc = "Preview Yank History" },
    gP = { "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "close_all_win" },
    gpd = { "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "goto_preview_definition" },
    gpi = { "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "goto_preview_implementation" },
    gpr = { "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "goto_preview_references" },
    gpt = {
      "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
      desc = "goto_preview_type_definition",
    },
  },
  v = { ["<leader>sw"] = { '<esc><cmd>lua require("spectre").open_visual()<CR>', desc = "Search current word" } },
  x = {
    ["<leader>re"] = { _9_, desc = "Extracts the selected code to a separate function" },
    ["<leader>rf"] = { _10_, desc = "Extract Function To File" },
    ["<leader>ri"] = { _11_, desc = "Inverse of extract variable" },
    ["<leader>rr"] = { _12_, desc = "Prompt for a refactor to apply" },
    ["<leader>rv"] = { _13_, desc = "Extracts occurrences of a selected expression to its own variable" },
  },
}
