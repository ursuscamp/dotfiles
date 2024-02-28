MiniDeps.add({
	source = "nvim-treesitter/nvim-treesitter",
	hooks = {
		post_install = function() vim.cmd(':TSUpdate') end,
	}
})

MiniDeps.later(function()
	require('nvim-treesitter.configs').setup({
		ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rust", "ruby", "html", "javascript", "typescript" },
		auto_install = true,
	})
end)
