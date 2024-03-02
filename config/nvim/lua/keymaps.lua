local util = require('util')

vim.keymap.set('n', 's', '<Nop>', { noremap = true })
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('n', 'U', '<cmd>redo<CR>', { noremap = true })

local function map_keys(k)
	for _, v in ipairs(k) do
		util.mapn(v[1], v[2], v[3])
	end
end

local nowkeys = {
	-- Some basics
	{ '<C-q>',      '<cmd>qa!<CR>',             'Quit all (w/o saving)' },
	{ '<leader>q',  '<cmd>q<CR>',               'Quit window' },
	{ '<leader>w',  '<cmd>w<CR>',               'Write buffer' },
	{ '<Esc>',      '<cmd>nohlsearch<CR>',      nil },

	-- Windows
	{ '<C-h>',      '<C-w><C-h>',               nil },
	{ '<C-j>',      '<C-w><C-j>',               nil },
	{ '<C-k>',      '<C-w><C-k>',               nil },
	{ '<C-l>',      '<C-w><C-l>',               nil },

	-- Buffers
	{ '<leader>bs', util.save_session,          'Save session with default name' },
	{ '<leader>bS', MiniSessions.select,        'Pick session' },
	{ '<leader>bv', '<cmd>vsplit<CR>',          'Split vertically' },
	{ '<leader>bh', '<cmd>split<CR>',           'Split horizontally' },

	-- Movement
	{ '[d',         vim.diagnostic.goto_prev,   "Previous diagnostic" },
	{ ']d',         vim.diagnostic.goto_next,   "Next diagnostic" },
	{ '<leader>lf', vim.lsp.buf.format,         "Format buffer" },
	{ 'gd',         vim.lsp.buf.declaration,    "Goto declaration" },
	{ 'gD',         vim.lsp.buf.definition,     "Goto definition" },
	{ 'ga',         vim.lsp.buf.code_action,    "Code actions" },
	{ 'gI',         vim.lsp.buf.implementation, "Goto implementation" },
	{ 'gr',         vim.lsp.buf.rename,         "Rename symbole" },
	{ 'K',          vim.lsp.buf.hover,          "Hover definition" },

	-- Git
	{ '<leader>gg', '<cmd>LazyGit<CR>',         'LazyGit' },
}

map_keys(nowkeys)

-- Due to plugin lazy loading, these must be set later
MiniDeps.later(function()
	local laterkeys = {
		{ '<leader>c',  MiniBufremove.delete,               "Close buffer" },
		{ '<leader>e',  MiniFiles.open,                     "Explore files" },

		-- -- Basic pickers
		{ '<leader>ff', MiniPick.builtin.files,             "Find files" },
		{ '<leader>fg', MiniPick.builtin.grep_live,         "Live grep" },
		{ '<leader>fG', '<cmd>Pick files tool=git<CR>',     "Find in git" },
		{ '<leader>fh', MiniPick.builtin.help,              "Find help" },
		{ '<leader>fb', MiniPick.builtin.buffers,           "Find open buffers" },
		{ '<leader>fk', MiniExtra.pickers.keymaps,          "Find keymaps" },
		{ '<leader>fo', MiniExtra.pickers.oldfiles,         "Find recent files" },
		{ '<leader>fd', util.buff_diagnostics,              "Find buffer diagnostics" },
		{ '<leader>fD', MiniExtra.pickers.diagnostic,       "Find all diagnostics" },
		{ '<leader>fs', MiniSessions.select,                "Open a session" },

		-- -- LSP pickers
		{ '<leader>ld', util.lsppicker("declaration"),      "Symbol declarations" },
		{ '<leader>lD', util.lsppicker("definition"),       "Symbol declarations" },
		{ '<leader>ls', util.lsppicker("document_symbol"),  "Symbol in document" },
		{ '<leader>lS', util.lsppicker("workspace_symbol"), "Symbol in workspace" },
		{ '<leader>li', util.lsppicker("implementation"),   "Symbol implementation" },
		{ '<leader>lr', util.lsppicker("references"),       "Symbol references" },
		{ '<leader>lt', util.lsppicker("type_definition"),  "Symbol type definition" },
	}

	map_keys(laterkeys)

	-- Flash
	vim.keymap.set({ 'n', 's', 'x' }, '<CR>', function() require('flash').jump() end,
		{ desc = "Flash jump", noremap = true })
	vim.keymap.set({ 'n', 's', 'x' }, '<C-]>', function() require('flash').treesitter() end,
		{ desc = "Flash jump", noremap = true })
end)
