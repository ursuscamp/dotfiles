return {
	"levouh/tint.nvim",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require('tint').setup({
			tint = -50,
			saturation = 0.8,
		})
	end
}
