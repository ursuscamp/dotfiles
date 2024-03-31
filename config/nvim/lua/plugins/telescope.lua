return {
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
			}
		},
		config = function()
			require('telescope').setup({
				defaults = {
					mappings = {
						i = {
							["<C-y>"] = require('telescope.actions').select_default,
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorts = true,
						case_mode = "smart_case",
					},
				},
			})
		end
	}
}
