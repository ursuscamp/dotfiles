MiniDeps.add({
	source = "catppuccin/nvim",
	name = "catppuccin",
})

MiniDeps.now(function()
	vim.cmd.colorscheme "catppuccin-macchiato"
end)
