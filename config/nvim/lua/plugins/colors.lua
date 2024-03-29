return {
	{ 'Mofiqul/dracula.nvim' },
	{ 'EdenEast/nightfox.nvim' },
	{ 'dasupradyumna/midnight.nvim' },
	{
		'folke/tokyonight.nvim',
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end
	}
}
-- MiniDeps.add({
-- 	source = "catppuccin/nvim",
-- 	name = "catppuccin",
-- })
--
-- MiniDeps.add('Mofiqul/dracula.nvim')
--
-- MiniDeps.add('EdenEast/nightfox.nvim')
--
-- MiniDeps.add('dasupradyumna/midnight.nvim')
--
-- MiniDeps.add('folke/tokyonight.nvim')
--
-- MiniDeps.now(function()
-- 	vim.cmd.colorscheme "tokyonight-night"
-- end)
