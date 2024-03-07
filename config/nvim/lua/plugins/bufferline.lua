MiniDeps.add({ source = 'akinsho/bufferline.nvim', checkout = "*", depends = { 'nvim-tree/nvim-web-devicons' } })

local bufferline = require('bufferline')

MiniDeps.now(function()
	bufferline.setup({
		options = {
			offsets = {
				{ filetype = "neo-tree" },
			},
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end

		},
	})
end)
