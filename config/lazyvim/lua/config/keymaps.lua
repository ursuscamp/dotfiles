-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("n", "<C-q>", ":qa!<CR>")
map("n", "<C-n>", ":BufferLineCycleNext<CR>")
map("n", "<C-p>", ":BufferLineCyclePrev<CR>")
map("n", "gb", ":BufferLinePick<CR>")
map("i", "jk", "<Esc>")

map("n", "<A-h>", require("smart-splits").resize_left)
map("n", "<A-j>", require("smart-splits").resize_down)
map("n", "<A-k>", require("smart-splits").resize_up)
map("n", "<A-l>", require("smart-splits").resize_right)
-- moving between splits
map("n", "<C-h>", require("smart-splits").move_cursor_left)
map("n", "<C-j>", require("smart-splits").move_cursor_down)
map("n", "<C-k>", require("smart-splits").move_cursor_up)
map("n", "<C-l>", require("smart-splits").move_cursor_right)
map("n", "<C-\\>", require("smart-splits").move_cursor_previous)

map("n", "<leader>e", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
map("n", "<leader>E", function()
  require("oil").open_float(vim.fn.getcwd())
end, { desc = "Open current working directory" })
