local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Better to save file & exit file --
keymap("n", "Q", ":q<CR>", opts)
keymap("n", "S", ":w<CR>", opts)

-- 'jk' key to exit insert mode --
keymap("i", "jk", "<Esc>", opts)

-- Better window navigation --
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Naviagate buffers --
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)

-- Stay in indent mode --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down --
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("v", "J", ":move '>+1<CR>gv-gv", opts)
keymap("v", "K", ":move '<-2<CR>gv-gv", opts)

-- Better split screen --
keymap("", "s", "<Nop>", opts)
keymap("n", "sl", ":set splitright<CR>:vsplit<CR>", opts)
keymap("n", "sh", ":set nosplitright<CR>:vsplit<CR>", opts)
keymap("n", "sk", ":set nosplitbelow<CR>:split<CR>", opts)
keymap("n", "sj", ":set splitbelow<CR>:split<CR>", opts)

--  Average adjustment window --
keymap("n", "<C-=>", "<C-w>=", opts)
-- Swap and move windows --
keymap("n", "<Space>h", "<C-w>H", opts)
keymap("n", "<Space>j", "<C-w>J", opts)
keymap("n", "<Space>k", "<C-w>K", opts)
keymap("n", "<Space>l", "<C-w>L", opts)

-- Adjust the direction of the split screen --
keymap("n", ",", "<C-w>t<C-w>K", opts)
keymap("n", ".", "<C-w>t<C-w>H", opts)

-- Resize the window --
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Better viewing of search results --
keymap("n", "<Space><CR>", ":nohlsearch<CR>", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)

-- tabnew
keymap("n", "<C-n>", ":tabnew<CR>", opts)
-- msic --
keymap("n", "<C-u>", "5k", opts)
keymap("n", "<C-d>", "5j", opts)
keymap("n", "<C-.>", "$", opts)
keymap("i", "<C-.>", "<ESC>$", opts)
keymap("x", "<C-.>", "$", opts)
keymap("v", "<C-.>", "$", opts)
keymap("n", "<C-,>", "^", opts)
keymap("i", "<C-,>", "<ESC>^", opts)
keymap("x", "<C-,>", "^", opts)
keymap("v", "<C-,>", "^", opts)
