MiniDeps.add({ source = 'Aasim-A/scrollEOF.nvim' })

MiniDeps.later(function()
	require('scrollEOF').setup()
end)
