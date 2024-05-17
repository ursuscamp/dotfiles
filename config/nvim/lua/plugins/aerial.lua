return {
	'stevearc/aerial.nvim',
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons"
	},
	event = "VeryLazy",
	config = function()
		require('aerial').setup()

		local open_aerial = function()
			require('aerial').toggle({ focus = true, direction = "left" })
		end
		vim.keymap.set("n", "<leader>o", open_aerial, { desc = "Open Aerial" })
	end,
}
