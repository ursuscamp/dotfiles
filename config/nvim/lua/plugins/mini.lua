require('mini.bufremove').setup()

require('mini.files').setup({
	mappings = {
		go_out = 'H',
		go_out_plus = 'h',
	}
})

vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = "Explore files" })


require('mini.statusline').setup()

require('mini.jump2d').setup()

require('mini.comment').setup()

require('mini.indentscope').setup({
	draw = {
		animation = function(s, n)
			return 2
		end,
	}
})

require('mini.pairs').setup()

require('mini.starter').setup()

require('mini.surround').setup()

require('mini.extra').setup()

require('mini.pick').setup({
	mappings = {
		choose_marked = '<C-S-CR>',
		move_down = '<C-j>',
		move_up = '<C-k>',
	}
})

-- Basic pickers
vim.keymap.set('n', '<leader>ff', MiniPick.builtin.files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', MiniPick.builtin.grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fG', function() MiniPick.builtin.files({ tool = "git" }) end, { desc = "Find git" })
vim.keymap.set('n', '<leader>fh', MiniPick.builtin.help, { desc = "Find help" })
vim.keymap.set('n', '<leader>fb', MiniPick.builtin.buffers, { desc = "Find help" })
vim.keymap.set('n', '<leader>fd', function() MiniExtra.pickers.diagnostic({ scope = "current" }) end,
	{ desc = "Find buffer diagnostics" })
vim.keymap.set('n', '<leader>fk', MiniExtra.pickers.keymaps, { desc = "Find keymaps" })
vim.keymap.set('n', '<leader>fo', MiniExtra.pickers.oldfiles, { desc = "Find recent files" })

-- LSP pickers
vim.keymap.set('n', '<leader>fD', MiniExtra.pickers.diagnostic, { desc = "Find all diagnostics" })
vim.keymap.set('n', '<leader>ld', function() MiniExtra.pickers.lsp({ scope = "declaration" }) end,
	{ desc = "Symbol declarations" })
vim.keymap.set('n', '<leader>lD', function() MiniExtra.pickers.lsp({ scope = "definition" }) end,
	{ desc = "Symbol definition" })
vim.keymap.set('n', '<leader>ls', function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end,
	{ desc = "Symbol in document" })
vim.keymap.set('n', '<leader>lS', function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end,
	{ desc = "Symbol in workspace" })
vim.keymap.set('n', '<leader>li', function() MiniExtra.pickers.lsp({ scope = "implementation" }) end,
	{ desc = "Symbol implementation" })
vim.keymap.set('n', '<leader>lr', function() MiniExtra.pickers.lsp({ scope = "references" }) end,
	{ desc = "Symbol references" })
vim.keymap.set('n', '<leader>lt', function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end,
	{ desc = "Symbol type definition" })
