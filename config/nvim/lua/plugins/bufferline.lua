return {
	{
		'akinsho/bufferline.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			local bufferline = require('bufferline')
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
		end
	}
}
