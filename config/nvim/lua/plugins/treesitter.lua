return {
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require('nvim-treesitter.configs').setup({
				ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rust", "ruby", "html", "javascript", "typescript" },
				auto_install = true,
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				}
			})

			require('treesitter-context').setup()
		end
	}
}
