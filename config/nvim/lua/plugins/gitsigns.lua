return {
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup({
				current_line_blame_opts = {
					delay = 300,
				}
			})
		end
	}
}
