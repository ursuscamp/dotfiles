return {
	'maxmx03/dracula.nvim',
	config = function()
		require('dracula').setup({
			transparent = true,
		})
		vim.cmd("colorscheme dracula")
	end
}
-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("tokyonight").setup({
-- 			transparent = true,
-- 		})
-- 		-- vim.cmd("colorscheme tokyonight-night")
-- 	end
-- }
