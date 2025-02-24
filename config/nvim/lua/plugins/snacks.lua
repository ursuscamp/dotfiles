return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				preset = {
					header = require('config.header')
				}
			},
			indent = {
				enabled = true,
				animate = {
					enabled = false,
				},
			},
			input = { enabled = true },
			picker = {
				enabled = true,
				matcher = {
					frecency = true,
				},
				win = {
					input = {
						keys = {
							["<C-y>"] = { "confirm", mode = { "n", "i" } },
						},
					},
				},
			},
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			lazygit = { enabled = true },
			image = { enabled = true },
			gitbrowse = { enabled = true },
			git = { enabled = true },
			bufdelete = { enabled = true },
			toggle = {},
		},
		keys = {
			{ "<leader>bd",      function() Snacks.bufdelete() end,                                      desc = "Delete buffer" },
			{ "<leader>bD",      function() Snacks.bufdelete.all() end,                                  desc = "Delete all buffers" },
			{ "<leader>gg",      function() Snacks.lazygit.open() end,                                   desc = "LazyGit" },
			{ "<leader>gx",      function() Snacks.lazygit.log() end,                                    desc = "LazyGit log" },
			{ "<leader>gX",      function() Snacks.lazygit.log_file() end,                               desc = "LazyGit log file" },
			{ "<leader>gB",      function() Snacks.gitbrowse() end,                                      desc = "Browse to git repo" },
			{ "<leader>gb",      function() Snacks.git.blame_line() end,                                 desc = "Git blame line" },
			{ "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files", },
			{ "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers", },
			{ "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep", },
			{ "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History", },
			{ "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History", },
			-- find
			{ "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers", },
			{ "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File", },
			{ "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files", },
			{ "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files", },
			{ "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects", },
			{ "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent", },
			-- git
			{ "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log", },
			{ "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line", },
			{ "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status", },
			{ "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)", },
			{ "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File", },
			-- Grep
			{ "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines", },
			{ "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers", },
			{ "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep", },
			{ "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" }, },
			-- search
			{ '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers", },
			{ "<leader>s/",      function() Snacks.picker.search_history() end,                          desc = "Search History", },
			{ "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds", },
			{ "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines", },
			{ "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History", },
			{ "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands", },
			{ "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics", },
			{ "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics", },
			{ "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages", },
			{ "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights", },
			{ "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons", },
			{ "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps", },
			{ "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps", },
			{ "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List", },
			{ "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks", },
			{ "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages", },
			{ "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec", },
			{ "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List", },
			{ "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume", },
			{ "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "Undo History", },
			{ "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes", },
			{ "<leader>sP",      function() Snacks.picker.pickers() end },
			-- LSP
			{ "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition", },
			{ "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration", },
			{ "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                     desc = "References", },
			{ "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation", },
			{ "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition", },
			{ "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols", },
			{ "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols", },

			-- todo comments
			{ "<leader>st",      function() Snacks.picker.todo_comments() end,                           desc = "Todo", },
		},
		config = function(_, opts)
			require('snacks').setup(opts)

			local t = require('snacks.toggle')
			t.inlay_hints():map("<leader>uh")
			t.diagnostics():map("<leader>ud")
			t.option("spell", { name = "Spelling" }):map("<leader>us")
			t.option("wrap", { name = "Wrap" }):map("<leader>uw")
			t.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
			t.diagnostics():map("<leader>ud")
			t.line_number():map("<leader>ul")
			t.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
			    :map("<leader>uc")
			t.treesitter():map("<leader>uT")
			t.option("background", { off = "light", on = "dark", name = "Dark Background" })
			    :map("<leader>ub")
			t.inlay_hints():map("<leader>uh")
			t.indent():map("<leader>ug")
			t.dim():map("<leader>uD")
			t.new({
				id = "compilot_cmp",
				name = "Copilot completion",
				get = function()
					return vim.g.copilot_cmp
				end,
				set = function(value)
					vim.g.copilot_cmp = value
				end,
			}):map("<leader>aC")
			t.new({
				id = "autoformat",
				name = "Autoformat",
				get = function()
					return vim.g.autoformat
				end,
				set = function(value)
					vim.g.autoformat = value
				end,
			}):map("<leader>cf")
		end
	},
}
