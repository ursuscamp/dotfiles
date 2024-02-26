MiniDeps.add(
	{
		source = 'nvim-telescope/telescope.nvim',
		checkout = '0.1.5',
		depends = { 'nvim-lua/plenary.nvim' },
	}
)

local function make_fzf_native(params)
	vim.cmd("lcd " .. params.path)
	vim.cmd("!make -s")
	vim.cmd("lcd -")
end

MiniDeps.add({
	source = "nvim-telescope/telescope-fzf-native.nvim",
	hooks = {
		post_install = make_fzf_native,
		post_checkout = make_fzf_native,
	}
})

require('telescope').setup()
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffer" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help" })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Old files" })
vim.keymap.set('n', '<leader>fC', builtin.colorscheme, { desc = "Color schemes" })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Key maps" })
vim.keymap.set('n', '<leader>fy', builtin.filetypes, { desc = "File types" })


-- LSP keys
vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = "References of symbol" })
vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set('n', '<leader>lS', builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set('n', '<leader>ld', builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set('n', '<leader>li', builtin.lsp_implementations, { desc = "Implementations of symbol" })
vim.keymap.set('n', '<leader>lt', builtin.lsp_definitions, { desc = "Declaration of symbol" })
vim.keymap.set('n', '<leader>lT', builtin.lsp_type_definitions, { desc = "Definition of symbol type" })
