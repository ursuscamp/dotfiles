MiniDeps.add({
	source = "catppuccin/nvim",
	name = "catppuccin",
})

MiniDeps.add('Mofiqul/dracula.nvim')

MiniDeps.now(function()
	vim.cmd.colorscheme "dracula"
end)
