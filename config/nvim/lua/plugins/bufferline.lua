return {
	'akinsho/bufferline.nvim',
	version = "*",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		'nvim-tree/nvim-web-devicons',
	},
	config = function()
		require('bufferline').setup({
			options = {
				separator_style = { ' ', '' },
				-- separator_style = 'slant',
			},
			highlights = {
				buffer_selected = {
					fg = require('dracula.palette').base04,
					bg = require('dracula.palette').purple,
				},
				close_button_selected = {
					fg = require('dracula.palette').base04,
					bg = require('dracula.palette').purple,
				},
				background = {
					fg = require('dracula.palette').purple,
					bg = require('dracula.palette').base03
				},
				close_button = {
					fg = require('dracula.palette').purple,
					bg = require('dracula.palette').base03,
				},
			},
		})

		vim.keymap.set('n', '<C-n>', '<cmd>BufferLineCycleNext<CR>', { desc = "Next buffer" })
		vim.keymap.set('n', '<C-p>', '<cmd>BufferLineCyclePrev<CR>', { desc = "Previous buffer" })
		vim.keymap.set('n', '<b', '<cmd>BufferLineMovePrev<CR>', { desc = "Move buffer back" })
		vim.keymap.set('n', '>b', '<cmd>BufferLineMoveNext<CR>', { desc = "Move buffer forward" })
		vim.keymap.set('n', '<leader>C', '<cmd>BufferLineCloseOthers<CR>', { desc = "Close other buffers" })
	end
}
