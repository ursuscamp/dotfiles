MiniDeps.add('j-hui/fidget.nvim')

MiniDeps.later(function()
	local fidget = require('fidget')
	fidget.setup({
		notification = {
			view = {
				stack_upwards = false,
			},
			window = {
				align = "top",
				max_width = 40,
			}
		}
	})

	vim.notify = fidget.notify
end)
