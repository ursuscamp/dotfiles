local nt = function()
	return require('neotest')
end

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"rouge8/neotest-rust",
		"olimorris/neotest-rspec",
	},
	cmd = "Neotest",
	keys = {
		{ '<leader>tt', function() nt().run.run() end,                     desc = 'Run nearest test' },
		{ '<leader>tf', function() nt().run.run(vim.fn.expand('%')) end,   desc = 'Run tests in current file' },
		{ '<leader>to', function() nt().output.open({ enter = true }) end, desc = 'Check test output' },
		{ '<leader>ts', function() nt().summary.toggle() end,              desc = 'Test summary' }
	},
	config = function()
		local nt = require('neotest')
		nt.setup({
			adapters = {
				require('neotest-rust'),
				require('neotest-rspec'),
			}
		})

		-- vim.keymap.set('n', '<leader>tt', function() nt.run.run() end, { desc = 'Run nearest test' })
		-- vim.keymap.set('n', '<leader>tf', function() nt.run.run(vim.fn.expand('%')) end,
		-- 	{ desc = 'Run tests in current file' })
		-- vim.keymap.set('n', '<leader>to', function() nt.output.open({ enter = true }) end,
		-- 	{ desc = 'Check test output' })
		-- vim.keymap.set('n', '<leader>ts', function() nt.summary.toggle() end, { desc = 'Test summary' })
	end
}
