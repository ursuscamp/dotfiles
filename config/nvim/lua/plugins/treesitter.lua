MiniDeps.add({
	source = "nvim-treesitter/nvim-treesitter",
	hooks = {
		post_install = function() vim.cmd(':TSUpdate') end,
	}
})

MiniDeps.add('nvim-treesitter/nvim-treesitter-context')

MiniDeps.later(function()
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
end)
