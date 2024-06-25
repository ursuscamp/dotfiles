return {
	"FabijanZulj/blame.nvim",
	cmd = 'ToggleBlame',
	keys = {
		{ '<leader>gb', '<cmd>BlameToggle window<CR>',  desc = "Toggle Git blame (window)" },
		{ '<leader>gB', '<cmd>BlameToggle virtual<CR>', desc = "Toggle Git blame (virtual)" },
	},
	opts = {},
}
