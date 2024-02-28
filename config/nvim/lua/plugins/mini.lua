MiniDeps.now(function()
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
		draw = {
			animation = function(s, n)
				return 2
			end,
		}
	})

	local starter = require('mini.starter')
	starter.setup({
		header = [[
		   _____ __                       __    __                        __
		  / ___// /_____  _________ ___  / /_  / /__  _____________  ____/ /
		  \__ \/ __/ __ \/ ___/ __ `__ \/ __ \/ / _ \/ ___/ ___/ _ \/ __  /
		 ___/ / /_/ /_/ / /  / / / / / / /_/ / /  __(__  |__  )  __/ /_/ /
		/____/\__/\____/_/  /_/ /_/ /_/_.___/_/\___/____/____/\___/\__,_/
		]],
		evaluate_single = true,
		items = {
			starter.sections.builtin_actions(),
			starter.sections.recent_files(10, true),
			starter.sections.pick(),
			-- Use this if you set up 'mini.sessions'
			-- starter.sections.sessions(5, true)
		},
		content_hooks = {
			starter.gen_hook.adding_bullet(),
			starter.gen_hook.indexing('all', { 'Builtin actions' }),
			starter.gen_hook.padding(3, 2),
		},

	})
end)

MiniDeps.later(function()
	require('mini.ai').setup()

	require('mini.bufremove').setup()

	require('mini.files').setup({
		mappings = {
			go_out = 'H',
			go_out_plus = 'h',
		}
	})

	require('mini.jump2d').setup()

	require('mini.comment').setup()

	require('mini.pairs').setup()


	require('mini.surround').setup()

	require('mini.extra').setup()

	require('mini.pick').setup({
		mappings = {
			choose_marked = '<C-S-CR>',
			move_down = '<C-j>',
			move_up = '<C-k>',
		}
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

			-- Modes
			{ mode = 'n', keys = 'v' },
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
			{ mode = 'n', keys = '<leader>s', desc = '+Split' },
		},
	})
end)
