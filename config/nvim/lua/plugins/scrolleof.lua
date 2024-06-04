return {
	'Aasim-A/scrollEOF.nvim',
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require('scrollEOF').setup()
	end
}
