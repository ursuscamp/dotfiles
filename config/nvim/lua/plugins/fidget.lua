MiniDeps.add({ source = "j-hui/fidget.nvim" })

MiniDeps.later(function()
	require('fidget').setup()
end)
