MiniDeps.add({
	source = "nvim-treesitter/nvim-treesitter",
	hooks = {
		post_install = function() vim.cmd(':TSUpdate') end,
	}
})

MiniDeps.add({ source = 'nvim-treesitter/nvim-treesitter-textobjects' })

MiniDeps.later(function()
	require('nvim-treesitter.configs').setup({
		ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rust", "ruby", "html", "javascript", "typescript" },
		auto_install = true,
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { query = "@function.outer", desc = "Around function" },
					["if"] = { query = "@function.inner", desc = "Inside function" },
					["ac"] = { query = "@class.outer", desc = "Around class/type" },
					["ic"] = { query = "@class.inner", desc = "Inside class/type" },
					["ap"] = { query = "@parameter.outer", desc = "Around parameter" },
					["ip"] = { query = "@parameter.inner", desc = "Inside parameter" },
				}
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]f"] = { query = "@function.outer", desc = "Next function" },
					["]c"] = { query = "@class.outer", desc = "Next class/type" },
					["]p"] = { query = "@parameter.outer", desc = "Next parameter" },
				},
				goto_previous_start = {
					["[f"] = { query = "@function.outer", desc = "Previous function" },
					["[c"] = { query = "@class.outer", desc = "Previous class/type" },
					["[p"] = { query = "@parameter.outer", desc = "Previous parameter" },
				}
			}
		}
	})
end)
