MiniDeps.add({ source = 'akinsho/bufferline.nvim', checkout = "*", depends = { 'nvim-tree/nvim-web-devicons' } })

local bufferline = require('bufferline')

MiniDeps.now(function()
	bufferline.setup({
		options = {
			offsets = {
				{ filetype = "neo-tree" },
			},
			diagnostics = "nvim_lsp",

		},
	})
end)
