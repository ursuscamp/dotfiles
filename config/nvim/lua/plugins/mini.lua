return {

	{
		"echasnovski/mini.nvim",
		version = "*",
		config = function()
			require("mini.basics").setup({
				options = {
					basic = true,
					extra_ui = true,
				},
				mappings = {
					windows = true,
				},
			})
			require("mini.pairs").setup()
			require("mini.surround").setup({
				mappings = {
					add = "gsa", -- Add surrounding in Normal and Visual modes
					delete = "gsd", -- Delete surrounding
					find = "gsf", -- Find surrounding (to the right)
					find_left = "gsF", -- Find surrounding (to the left)
					highlight = "gsh", -- Highlight surrounding
					replace = "gsr", -- Replace surrounding
					update_n_lines = "gsn", -- Update `n_lines`

					suffix_last = "l", -- Suffix to search with "prev" method
					suffix_next = "n", -- Suffix to search with "next" method
				},
			})
			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons()
			require("mini.ai").setup()
			require("mini.files").setup()
			require('mini.splitjoin').setup()
			require('mini.diff').setup({
				view = {
					style = "sign",
					signs = {
						add = "┃",
						change = "┃",
						delete = "┃",
					},
				}
			})

			require('snacks.toggle').new({
				id = "diff_overlay",
				name = "Git Diff overlay",
				get = function()
					return vim.g.diff_overlay
				end,
				set = function(value)
					vim.g.diff_overlay = value
					MiniDiff.toggle_overlay(0)
				end,
			}):map("<leader>gO")
		end,
		keys = {
			{ "<leader>E", function() MiniFiles.open() end,                                    desc = "Explore files" },
			{ "<leader>e", function() MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end, desc = "Explore files (current buffer dir)" },
		}
	},
}
