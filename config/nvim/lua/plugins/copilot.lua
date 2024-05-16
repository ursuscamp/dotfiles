-- Load this plugin only on my work machine
if vim.fn.getenv('USER') ~= 'rbreen' then
	return {
		'github/copilot.vim',
		cmd = 'Copilot',
	}
end
