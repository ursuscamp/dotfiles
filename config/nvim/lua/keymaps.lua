vim.keymap.set('n', '<C-q>', ':qa!<CR>', { desc = "Quit all (w/o saving)" })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = "Quit window" })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Write buffer" })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

MiniDeps.later(function()
	vim.keymap.set('n', '<leader>c', MiniBufremove.delete, { desc = "Close buffer" })
	vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = "Explore files" })
end)



-- Window stuff
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = "Split vertically" })
vim.keymap.set('n', '<leader>sh', '<cmd>split<CR>', { desc = "Split vertically" })


-- Movement and goto
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { desc = "Goto declaration" })
vim.keymap.set('n', 'gD', vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = "Goto implementation" })


-- Basic pickers
MiniDeps.later(function()
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
end)
