local util = require('util')

vim.keymap.set('n', 's', '<Nop>', { noremap = true })
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('n', 'U', '<cmd>redo<CR>', { noremap = true })

local function map_keys(k)
	for _, v in ipairs(k) do
		util.mapn(v[1], v[2], v[3])
	end
end

local builtin = require('telescope.builtin')

local nowkeys = {
	-- Some basics
	{ '<C-q>',      '<cmd>qa!<CR>',                 'Quit all (w/o saving)' },
	{ '<leader>q',  '<cmd>q<CR>',                   'Quit window' },
	{ '<leader>w',  '<cmd>w<CR>',                   'Write buffer' },
	{ '<Esc>',      '<cmd>nohlsearch<CR>',          nil },

	-- Windows
	{ '<C-h>',      '<C-w><C-h>',                   nil },
	{ '<C-j>',      '<C-w><C-j>',                   nil },
	{ '<C-k>',      '<C-w><C-k>',                   nil },
	{ '<C-l>',      '<C-w><C-l>',                   nil },

	-- Buffers
	{ '<leader>bv', '<cmd>vsplit<CR>',              'Split vertically' },
	{ '<leader>bh', '<cmd>split<CR>',               'Split horizontally' },
	{ ']b',         '<cmd>BufferLineCycleNext<CR>', 'Next buffer' },
	{ '[b',         '<cmd>BufferLineCyclePrev<CR>', 'Previous buffer' },
	{ '>b',         '<cmd>BufferLineMoveNext<CR>',  'Move buffer right' },
	{ '<b',         '<cmd>BufferLineMovePrev<CR>',  'Move buffer left' },
	{ '<C-n>',      '<cmd>BufferLineCycleNext<CR>', 'Next buffer' },
	{ '<C-p>',      '<cmd>BufferLineCyclePrev<CR>', 'Previous buffer' },

	-- Movement
	{ '[d',         vim.diagnostic.goto_prev,       "Previous diagnostic" },
	{ ']d',         vim.diagnostic.goto_next,       "Next diagnostic" },
	{ '<leader>lf', vim.lsp.buf.format,             "Format buffer" },
	{ 'gD',         vim.lsp.buf.declaration,        "Goto declaration" },
	{ 'gd',         builtin.lsp_definitions,        "Goto definition" },
	{ 'ga',         vim.lsp.buf.code_action,        "Code actions" },
	{ 'gI',         builtin.lsp_implementations,    "Goto implementation" },
	{ 'gr',         vim.lsp.buf.rename,             "Rename symbole" },
	{ 'K',          vim.lsp.buf.hover,              "Hover definition" },

	-- Git
	{ '<leader>gg', '<cmd>LazyGit<CR>',             'LazyGit' },
	{ '<leader>gb', function()
		require('gitsigns').blame_line({ full = true })
	end, 'Git blame' },
	{ '<leader>gB', require('gitsigns').toggle_current_line_blame, 'Toggle line blame' },
}

map_keys(nowkeys)

-- Due to plugin lazy loading, these must be set later
local laterkeys = {
	{ '<leader>c',  MiniBufremove.delete,                 "Close buffer" },
	{ '<leader>C',  '<cmd>BufferLineCloseOther<CR>',      "Close other buffers" },
	{ '<leader>e',  MiniFiles.open,                       "Explore files" },

	-- -- Basic pickers
	{ '<leader>ff', builtin.find_files,                   "Find files" },
	{ '<leader>fg', builtin.live_grep,                    "Live grep" },
	{ '<leader>fG', builtin.git_files,                    "Find in git" },
	{ '<leader>fh', builtin.help_tags,                    "Find help" },
	{ '<leader>fb', builtin.buffers,                      "Find open buffers" },
	{ '<leader>fk', builtin.keymaps,                      "Find keymaps" },
	{ '<leader>fo', builtin.oldfiles,                     "Find recent files" },
	{ '<leader>fd', ':Telescope diagnostics bufnr=0<CR>', "Find buffer diagnostics" },
	{ '<leader>fD', builtin.diagnostics,                  "Find all diagnostics" },
	{ '<leader>fr', builtin.registers,                    "Registers" },
	{ '<leader>fy', builtin.filetypes,                    "File types" },

	-- -- LSP pickers
	{ '<leader>ld', builtin.lsp_definitions,              "Symbol declarations" },
	{ '<leader>ls', builtin.lsp_document_symbols,         "Symbol in document" },
	{ '<leader>lS', builtin.lsp_workspace_symbols,        "Symbol in workspace" },
	{ '<leader>li', builtin.lsp_implementations,          "Symbol implementation" },
	{ '<leader>lr', builtin.lsp_references,               "Symbol references" },
	{ '<leader>lt', builtin.lsp_type_definitions,         "Symbol type definition" },
}

map_keys(laterkeys)

-- Flash
vim.keymap.set({ 'n', 's', 'x' }, '<CR>', function() require('flash').jump() end,
	{ desc = "Flash jump", noremap = true })
vim.keymap.set({ 'n', 's', 'x' }, '<S-Enter>', function() require('flash').treesitter() end,
	{ desc = "Flash jump", noremap = true })
