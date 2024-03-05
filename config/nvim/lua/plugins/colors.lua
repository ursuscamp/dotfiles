MiniDeps.add({
	source = "catppuccin/nvim",
	name = "catppuccin",
})

MiniDeps.add('Mofiqul/dracula.nvim')

MiniDeps.add('EdenEast/nightfox.nvim')

MiniDeps.now(function()
	vim.cmd.colorscheme "nightfox"
end)
