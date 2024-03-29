return { {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				markdown = { { "prettierd", "prettier" } },
				ruby = { "rubocop" },
				python = { "isort", "black" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = true,
			}
		})
	end
}
}
