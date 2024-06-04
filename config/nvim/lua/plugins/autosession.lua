-- return {}
return {
	'rmagatti/auto-session',
	config = function()
		require('auto-session').setup({
			session_lens = {
				load_on_setup = false,
			}
		})
	end,
}
