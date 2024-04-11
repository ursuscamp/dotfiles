return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
	    'nvim-lua/plenary.nvim',
	    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    },
    event = 'VeryLazy',
    config = function()
	    local actions = require('telescope.actions')
	    require('telescope').setup({
		    defaults = {
			    mappings = {
				    i = {
					    ["<C-y>"] = actions.select_default,
				    },
			    },
		    },
	    })
	    require('telescope').load_extension('fzf')
	    local builtin = require('telescope.builtin')

	    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
	    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
	    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find buffers" })
	    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find help" })
	    vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = "Find commands" })
	    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find keymaps" })
	    vim.keymap.set('n', '<leader>fy', builtin.filetypes, { desc = "Select filetype" })


	    -- LSP
	    vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = "Find references under cursor" })
	    vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = "Find document symbols" })
	    vim.keymap.set('n', '<leader>lS', builtin.lsp_workspace_symbols, { desc = "Find workspace symbols" })
	    vim.keymap.set('n', '<leader>ld', builtin.diagnostics, { desc = "Diagnostics" })
	    vim.keymap.set('n', '<leader>li', builtin.lsp_implementations, { desc = "Find implementations under cursor" })
	    vim.keymap.set('n', '<leader>lD', builtin.lsp_definitions, { desc = "Find definitions under cursor" })
	    vim.keymap.set('n', '<leader>lt', builtin.lsp_type_definitions, { desc = "Find type definition under cursor" })
    end,
}
