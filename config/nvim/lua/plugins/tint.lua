return {
	"levouh/tint.nvim",
	config = function()
		require('tint').setup({
			tint = -80,
			saturation = 0.8,
		})
	end
}