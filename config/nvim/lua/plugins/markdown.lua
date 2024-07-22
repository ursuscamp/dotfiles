local function toggle()
	require('render-markdown').toggle()
end

return {
	'MeanderingProgrammer/markdown.nvim',
	name = 'render-markdown',
	dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
	ft = { 'markdown' },
	cmd = { 'RenderMarkdown' },
	keys = {
		{ '<leader>zm', toggle, desc = 'Toggle RenderMarkdown' },
	},
	config = function()
		require('render-markdown').setup({})
	end,
}
