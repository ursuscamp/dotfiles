return {
	"FabijanZulj/blame.nvim",
	cmd = 'ToggleBlame',
	keys = {
		{ '<leader>gb', '<cmd>ToggleBlame window<CR>',  desc = "Toggle Git blame (window)" },
		{ '<leader>gB', '<cmd>ToggleBlame virtual<CR>', desc = "Toggle Git blame (virtual)" },
	},
	opts = {},
}
