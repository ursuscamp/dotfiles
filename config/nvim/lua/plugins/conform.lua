return {
	'stevearc/conform.nvim',
	event = { 'BufReadPost', 'BufNewFile' },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettier" },
				rust = { "rustfmt" },
				markdown = { "prettier" },
				json = { "prettier" },
				vue = { "prettier" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_fallback = true,
			},
		})
	end
}
