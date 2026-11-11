-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Option-Backspace deletes the previous word without leaving Insert mode.
vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Delete previous word" })
