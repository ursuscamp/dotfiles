local function checkbox()
	local line = vim.api.nvim_get_current_line()
	-- if the line starts with '- ' then replace it with '- [ ]'
	if string.match(line, '- 󰄱') then
		line = string.gsub(line, '- 󰄱', '- ')
	elseif string.match(line, '- ') then
		line = string.gsub(line, '- ', '- 󰄱')
	elseif string.match(line, '^%s*- ') then
		line = string.gsub(line, '^(%s*)- ', '%1- 󰄱 ')
	end
	vim.api.nvim_set_current_line(line)
end

local status, wk = pcall(require, 'which-key')
if (not status) then
	vim.keymap.set('n', '<leader>zc', checkbox, { desc = 'Mark/create checkbox', buffer = true })
else
	wk.add({
		{ '<leader>z',  group = "Miscellaneous" },
		{ '<leaxer>zc', checkbox,               desc = 'Mark/create checkbox' },
	})
end
