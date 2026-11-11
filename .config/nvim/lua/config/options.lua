-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Keep the gutter and cursor position easy to read.
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.showcmd = false

-- Hard-wrap at 80 columns and mark the limit.
-- Code only wraps comments; prose filetypes also wrap text (see autocmds.lua).
vim.opt.textwidth = 80
vim.opt.colorcolumn = "+1"
