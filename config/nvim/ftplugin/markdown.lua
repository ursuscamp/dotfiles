local function checkbox()
	local line = vim.api.nvim_get_current_line()
	-- if the line starts with '- ' then replace it with '- [ ]'
	if string.match(line, '- %[ ]') then
		line = string.gsub(line, '- %[ ]', '- [x]')
	elseif string.match(line, '- %[x]') then
		line = string.gsub(line, '- %[x]', '- [ ]')
	elseif string.match(line, '^%s*- ') then
		line = string.gsub(line, '^(%s*)- ', '%1- [ ] ')
	end
	vim.api.nvim_set_current_line(line)
end

vim.keymap.set('n', '<leader>zc', checkbox, { desc = 'Mark/create checkbox', buffer = true })
