return {
	'stevearc/oil.nvim',
	event = 'VeryLazy',
	config = function()
		require('oil').setup({
			keymaps = {
				["h"] = "actions.parent",
				["l"] = "actions.select",
			},
		})

		vim.keymap.set('n', '<leader>e', '<cmd>Oil --float<CR>', { desc = "Open file explorer" })
	end,
}
