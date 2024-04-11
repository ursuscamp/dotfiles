return {
	"FabijanZulj/blame.nvim",
	event = 'VeryLazy',
	config = function()
		require('blame').setup()

		vim.keymap.set('n', '<leader>gb', '<cmd>ToggleBlame window<CR>', { desc = "Toggle Git blame (window)" })
		vim.keymap.set('n', '<leader>gB', '<cmd>ToggleBlame virtual<CR>', { desc = "Toggle Git blame (virtual)" })
	end
}
