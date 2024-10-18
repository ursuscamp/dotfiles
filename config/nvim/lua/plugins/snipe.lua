return {
	{
		"leath-dub/snipe.nvim",
		keys = {
			{
				"<leader>b",
				function()
					require("snipe").open_buffer_menu()
				end,
				desc = "Open Snipe buffer menu",
			},
		},
		opts = {
			ui = {
				position = "cursor",
			},
			navigate = {
				under_cursor = "<c-y>",
				cancel_snipe = "<c-c>",
			},
		},
	},
}
