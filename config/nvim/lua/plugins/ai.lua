local function copilot_model()
	if vim.g.work_computer then
		return "claude-3.7-sonnet"
	else
		return "gpt-4o"
	end
end

return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enable = false },
			panel = { enable = false }
		},
	},
	{
		"giuxtaposition/blink-cmp-copilot"
	},
}
