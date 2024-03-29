MiniDeps.add({
	source = 'nvim-telescope/telescope.nvim',
	checkout = '0.1.x',
	depends = { 'nvim-lua/plenary.nvim' }
})

MiniDeps.add({
	source = 'nvim-telescope/telescope-fzf-native.nvim',
	hooks = {
		post_install = function()
			vim.api.nvim_command(':!make')
		end
	}
})

MiniDeps.later(function()
	require('telescope').setup({
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorts = true,
				case_mode = "smart_case",
			},
		},
	})
end)
