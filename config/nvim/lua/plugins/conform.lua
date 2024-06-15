local function toggle_format_one_save()
	vim.g.format_on_save_disabled = not vim.g.format_on_save_disabled
	if vim.g.format_on_save_disabled then
		vim.notify("Format on save disabled")
	else
		vim.notify("Format on save enabled")
	end
end

return {
	'stevearc/conform.nvim',
	event = { 'BufReadPost', 'BufNewFile' },
	config = function()
		vim.keymap.set('n', '<leader>F', toggle_format_one_save, { desc = "Toggle format on save" })
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
			format_on_save = function(bufnr)
				if vim.g.format_on_save_disabled then
					return
				end
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
		})
	end
}
