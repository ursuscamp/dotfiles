MiniDeps.add({ source = 'lewis6991/gitsigns.nvim' })

MiniDeps.now(function()
	require('gitsigns').setup()
end)
