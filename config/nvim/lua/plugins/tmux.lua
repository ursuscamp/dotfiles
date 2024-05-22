return {
	"aserowy/tmux.nvim",
	config = function()
		require("tmux").setup({
			resize = {
				enable_default_keybindings = true,
				resize_step_x = 15,
				resize_step_y = 5,
			},
		})
	end
}
