--Revert to where the cursor was when the file was last closed
vim.cmd([[autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif]])

vim.cmd([[set iskeyword+=-]])

vim.cmd("set whichwrap+=<,>,[,],h,l")
-- about fold
vim.cmd("set foldmethod=expr")
vim.cmd("set foldexpr=nvim_treesitter#foldexpr()")
-- vim.cmd([[autocmd BufReadPost,FileReadPost * normal zR]])

-- set bg transparent
--vim.cmd([[autocmd ColorScheme * highlight Normal guibg=NONE ctermbg=NONE]])
