return {
	{
		'echasnovski/mini.nvim',
		version = false,
		config = function()
			require('mini.basics').setup({
				options = {
					basic = true,
					extra_ui = true,
					win_borders = 'bold'
				},
				mappings = {
					basic = false,
					window = false,
					move_with_alt = false,
				},
				autocommands = {
					basic = true,
					relnum_in_visual_mode = false,
				}
			})

			require('mini.statusline').setup()

			require('mini.indentscope').setup({
				symbol = '│',
				draw = {
					animation = function()
						return 2
					end,
				}
			})

			require('mini.cursorword').setup()

			require('mini.ai').setup()

			require('mini.bufremove').setup()

			require('mini.files').setup({
				mappings = {
					go_out = 'H',
					go_out_plus = 'h',
				}
			})

			require('mini.comment').setup()

			require('mini.pairs').setup()


			require('mini.surround').setup()

			require('mini.extra').setup()

			require('mini.bracketed').setup({
				buffer     = { suffix = '', options = {} },
				comment    = { suffix = 'c', options = {} },
				conflict   = { suffix = 'x', options = {} },
				diagnostic = { suffix = 'd', options = {} },
				file       = { suffix = '', options = {} },
				indent     = { suffix = '', options = {} },
				jump       = { suffix = '', options = {} },
				location   = { suffix = '', options = {} },
				oldfile    = { suffix = '', options = {} },
				quickfix   = { suffix = 'q', options = {} },
				treesitter = { suffix = 't', options = {} },
				undo       = { suffix = '', options = {} },
				window     = { suffix = '', options = {} },
				yank       = { suffix = '', options = {} },
			})

			local miniclue = require('mini.clue')
			miniclue.setup({
				window = {
					config = {
						anchor = "SW", row = "auto", col = "auto"
					}
				},
				triggers = {
					-- Leader triggers
					{ mode = 'n', keys = '<Leader>' },
					{ mode = 'x', keys = '<Leader>' },

					-- Built-in completion
					{ mode = 'i', keys = '<C-x>' },

					-- `g` key
					{ mode = 'n', keys = 'g' },
					{ mode = 'x', keys = 'g' },

					-- Marks
					{ mode = 'n', keys = "'" },
					{ mode = 'n', keys = '`' },
					{ mode = 'x', keys = "'" },
					{ mode = 'x', keys = '`' },

					-- Registers
					{ mode = 'n', keys = '"' },
					{ mode = 'x', keys = '"' },
					{ mode = 'i', keys = '<C-r>' },
					{ mode = 'c', keys = '<C-r>' },

					-- Window commands
					{ mode = 'n', keys = '<C-w>' },

					-- `z` key
					{ mode = 'n', keys = 'z' },
					{ mode = 'x', keys = 'z' },

					-- Moves
					{ mode = 'n', keys = ']' },
					{ mode = 'x', keys = ']' },
					{ mode = 'n', keys = '[' },
					{ mode = 'x', keys = '[' },

					-- Surround
					{ mode = 'n', keys = 's' },
					{ mode = 'x', keys = 's' },
				},

				clues = {
					-- Enhance this by adding descriptions for <Leader> mapping groups
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
					{ mode = 'n', keys = '<leader>l', desc = '+LSP Actions' },
					{ mode = 'n', keys = '<leader>f', desc = '+Find' },
					{ mode = 'n', keys = '<leader>b', desc = '+Buffer' },
				},
			})
		end
	}
}
