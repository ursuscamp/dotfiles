return {
	'lewis6991/gitsigns.nvim',
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require('gitsigns').setup()
		vim.keymap.set('n', '[h', function() require('gitsigns').prev_hunk() end, { desc = 'Previous hunk' })
		vim.keymap.set('n', ']h', function() require('gitsigns').next_hunk() end, { desc = 'Next hunk' })
	end
}
