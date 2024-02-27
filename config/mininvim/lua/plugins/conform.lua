MiniDeps.add({ source = "stevearc/conform.nvim" })

require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		html = { "prettier" },
		markdown = { "prettier" },
		ruby = { "rubocop" },
		python = { "isort", "black" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	}
})
