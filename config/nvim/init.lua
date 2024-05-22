-- CONFIG
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.termguicolors = true

-- HIGHLIGHT YANKED TEXT
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- LAZY.NVIM
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- KEYMAPS
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Write buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>c', '<cmd>bdelete!<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<C-q>', '<cmd>qa!<CR>', { desc = 'Close Neovim' })
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Leave insert mode' })
vim.keymap.set('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = 'Split vertically' })
vim.keymap.set('n', '<leader>sh', '<cmd>split<CR>', { desc = 'Split horizontally' })
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { desc = "Hover info" })
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { desc = "Goto definition" })
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { desc = "Goto declaration" })
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { desc = "Goto implementation" })
vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { desc = "Goto type definition" })
vim.keymap.set('n', 'gR', '<cmd>lua vim.lsp.buf.references()<cr>', { desc = "Goto references" })
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<cr>', { desc = "Rename" })
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', { desc = "Code actions" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto next diagnostic' })

-- vim.keymap.set({ 'n', 'v' }, '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set({ 'n', 'v' }, '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set({ 'n', 'v' }, '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set({ 'n', 'v' }, '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
