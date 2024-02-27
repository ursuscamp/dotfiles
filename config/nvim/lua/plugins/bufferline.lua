MiniDeps.add({ source = 'akinsho/bufferline.nvim', checkout = "*", depends = { 'nvim-tree/nvim-web-devicons' } })

local bufferline = require('bufferline')

bufferline.setup({
	options = {
		offsets = {
			{ filetype = "neo-tree" },
		},

	},
})

vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', '>b', '<cmd>BufferLineMoveNext<CR>', { desc = "Move buffer right" })
vim.keymap.set('n', '<b', '<cmd>BufferLineMovePrev<CR>', { desc = "Move buffer left" })
