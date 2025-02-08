return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("tokyonight-storm")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = {
				enable = true,
				disable = { "ruby" },
			},
		},
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = 0,
			spec = {
				{ "<leader>a", group = "AI" },
				{ "<leader>f", group = "File" },
				{ "<leader>g", group = "Git" },
				{ "<leader>s", group = "Search/Snacks" },
				{ "<leader>u", group = "UI" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
	},
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = "echasnovski/mini.nvim",
		opts = {},
		keys = {
			{ "H",          vim.cmd.BufferLineCyclePrev,   desc = "Previous buffer" },
			{ "L",          vim.cmd.BufferLineCycleNext,   desc = "Next buffer" },
			{ "[B",         vim.cmd.BufferLineMovePrev,    desc = "Move buffer left", },
			{ "]B",         vim.cmd.BufferLineMoveNext,    desc = "Move buffer right", },
			{ "<c-f>",      vim.cmd.BufferLinePick,        desc = "Pick buffer" },
			{ "<leader>bp", vim.cmd.BufferLineTogglePin,   desc = "Toggle pin" },
			{ "<leader>bc", vim.cmd.BufferLineCloseOthers, desc = "Close other buffers" },
			{ "<leader>br", vim.cmd.BufferLineCloseRight,  desc = "Close to right" },
			{ "<leader>bl", vim.cmd.BufferLineCloseLeft,   desc = "Close to left" },
		}
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = "echasnovski/mini.nvim",
		opts = {},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"mrjones2014/smart-splits.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "<a-h>", vim.cmd.SmartRezizeLeft,      desc = "Resize left" },
			{ "<a-j>", vim.cmd.SmartResizeRight,     desc = "Resize right" },
			{ "<a-j>", vim.cmd.SmartResizeDown,      desc = "Resize down" },
			{ "<a-k>", vim.cmd.SmartResizeUp,        desc = "Resize up" },
			{ "<c-h>", vim.cmd.SmartCursorMoveLeft,  desc = "Move left" },
			{ "<c-j>", vim.cmd.SmartCursorMoveDown,  desc = "Move down" },
			{ "<c-k>", vim.cmd.SmartCursorMoveUp,    desc = "Move up" },
			{ "<c-l>", vim.cmd.SmartCursorMoveRight, desc = "Move right" },
		}
	},
	{
		'Aasim-A/scrollEOF.nvim',
		event = { 'CursorMoved', 'WinScrolled' },
		opts = {},
	}
}
