local options = {
	clipboard = "unnamedplus",
	mouse = "a",
	undofile = true,
	ignorecase = true,
	smartcase = true,
	showmode = false,
	showtabline = 2,
	smartindent = true,
	autoindent = true,
	swapfile = true,
	hidden = true, --default on
	expandtab = false,
	cmdheight = 1,
	shiftwidth = 4, --insert 4 spaces for each indentation
	tabstop = 4, --insert 4 spaces for a tab
	cursorline = false, --Highlight the line where the cursor is located
	cursorcolumn = false,
	number = true,
	numberwidth = 4,
	relativenumber = true,
	--[[ wrap = false, ]]
	scrolloff = 8,
	fileencodings = "utf-8,gbk",
	updatetime = 50, -- faster completion (4000ms default)
	foldenable = false,
	foldlevel = 99,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
