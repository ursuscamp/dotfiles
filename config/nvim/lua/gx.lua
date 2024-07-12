-- Found here: https://www.reddit.com/r/neovim/comments/1dzzat3/a_dumb_and_naive_gx_optimization/
vim.ui.open = (function(overridden)
	return function(path)
		vim.validate({
			path = { path, 'string' },
		})
		local is_uri = path:match('%w+:')
		local is_half_url = path:match('%.com$') or path:match('%.com%.')
		local is_repo = vim.bo.filetype == 'lua' and path:match('%w/%w') and vim.fn.count(path, '/') == 1
		local is_dir = path:match('/%w')
		if not is_uri then
			if is_half_url then
				path = ('https://%s'):format(path)
			elseif is_repo then
				path = ('https://github.com/%s'):format(path)
			elseif not is_dir then
				path = ('https://google.com/search?q=%s'):format(path)
			end
		end
		overridden(path)
	end
end)(vim.ui.open)
