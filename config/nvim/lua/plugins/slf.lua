return {
	'ursuscamp/slf.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	keys = {
		{ '<leader>zl', ':Slf<CR>', desc = 'Log to SLF' },
	},
	config = function()
		require('slf').setup()
	end
}
