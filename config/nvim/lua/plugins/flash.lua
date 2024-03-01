MiniDeps.add('folke/flash.nvim')

MiniDeps.later(function()
	require('flash').setup()
end)
