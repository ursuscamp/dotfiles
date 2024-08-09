return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"vim",
				"vimdoc",
				"rust",
				"html",
				"javascript",
				"typescript",
				"diff",
			},
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
		})
	end,
}
