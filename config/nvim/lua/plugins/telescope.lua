local t = function(c)
	return function()
		return require('telescope.builtin')[c]()
	end
end

return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		'benfowler/telescope-luasnip.nvim',
	},
	cmd = 'Telescope',
	keys = {
		{ '<leader>ff', t('find_files'),            desc = "Find files" },
		{ '<leader>fg', t('live_grep'),             desc = "Live grep" },
		{ '<leader>fb', t('buffers'),               desc = "Find buffers" },
		{ '<leader>fh', t('help_tags'),             desc = "Find help" },
		{ '<leader>fc', t('commands'),              desc = "Find commands" },
		{ '<leader>fk', t('keymaps'),               desc = "Find keymaps" },
		{ '<leader>fy', t('filetypes'),             desc = "Select filetype" },
		{ '<leader>fs', t('luasnip'),               desc = "Find snippets" },

		-- LSP
		{ '<leader>lr', t('lsp_references'),        desc = "Find references under cursor" },
		{ '<leader>ls', t('lsp_document_symbols'),  desc = "Find document symbols" },
		{ '<leader>lS', t('lsp_workspace_symbols'), desc = "Find workspace symbols" },
		{ '<leader>ld', t('diagnostics'),           desc = "Diagnostics" },
		{ '<leader>li', t('lsp_implementations'),   desc = "Find implementations under cursor" },
		{ '<leader>lD', t('lsp_definitions'),       desc = "Find definitions under cursor" },
		{ '<leader>lt', t('lsp_type_definitions'),  desc = "Find type definition under cursor" },
	},
	config = function()
		local telescope = require('telescope')
		local actions = require('telescope.actions')
		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-y>"] = actions.select_default,
					},
				},
			},
		})
		telescope.load_extension('fzf')
		telescope.load_extension('luasnip')
	end,
}
