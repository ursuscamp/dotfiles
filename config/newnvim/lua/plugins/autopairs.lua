return {
	'windwp/nvim-autopairs',
	dependencies = { 'windwp/nvim-ts-autotag' },
	event = 'InsertEnter',
	config = function()
		require('nvim-autopairs').setup({
			check_ts = true,
		})
		local cmp_autopairs = require('nvim-autopairs.completion.cmp')
		local cmp = require('cmp')
		cmp.event:on(
			'confirm_done',
			cmp_autopairs.on_confirm_done()
		)

		require('nvim-ts-autotag').setup()
	end,
}
