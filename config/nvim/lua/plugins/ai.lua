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
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		opts = {},
		cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatModels" },
		keys = {
			{ "<leader>ac", mode = { "n", "x", "o" }, vim.cmd.CoppilotChatToggle, desc = "Toggle Copilot Chat" },
			{ "<leader>am", mode = { "n", "x", "o" }, vim.cmd.CopilotChatModels,  desc = "Pick chat model" },
		},
	},
}
