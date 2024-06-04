return {
	'kevinhwang91/nvim-ufo',
	dependencies = { 'kevinhwang91/promise-async' },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		vim.o.foldcolumn = '1' -- '0' is not bad
		vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		local ufo = require('ufo')
		vim.keymap.set('n', 'zR', ufo.openAllFolds)
		vim.keymap.set('n', 'zM', ufo.closeAllFolds)

		require('ufo').setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { 'treesitter', 'indent' }
			end
		})
	end
}
