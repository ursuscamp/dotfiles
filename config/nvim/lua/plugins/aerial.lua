local open_aerial = function()
	require('aerial').toggle({ focus = true, direction = "left" })
end

return {
	'stevearc/aerial.nvim',
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons"
	},
	keys = {
		{ '<leader>o', open_aerial, desc = "Open Aerial" }
	},
	opts = {},
}
