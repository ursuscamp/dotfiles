MiniDeps.add({ source = 'lewis6991/gitsigns.nvim' })

-- hello
MiniDeps.now(function()
	require('gitsigns').setup({
		current_line_blame_opts = {
			delay = 300,
		}
	})
end)
