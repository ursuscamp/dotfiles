return {
	"folke/which-key.nvim",
	dependencies = {
		"echasnovski/mini.icons",
		"https://github.com/nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		require('which-key').setup({
			spec = {
				{ "<leader>f",  group = "Find" },
				{ "<leader>g",  group = "Git" },
				{ "<leader>gc", group = "Github Copilot" },
				{ "<leader>l",  group = "LSP" },
				{ "<leader>s",  group = "Split" },
				{ "<leader>t",  group = "Tests" },
				{ "<leader>x",  group = "Trouble lists" },
			}
		})
	end
}
