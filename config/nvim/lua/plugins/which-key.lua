return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		require('which-key').register({
			g = { name = 'Git' },
			gc = { name = 'Github Copilot' },
			l = { name = 'LSP' },
			s = { name = 'Split' },
			f = { name = 'Find' },
			t = { name = 'Tests' },
		}, { prefix = '<leader>' })
	end
}
