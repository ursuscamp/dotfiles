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
		cmd = { "CopilotChat", "CopilotChatToggle" },
		keys = {
			{ "<leader>ac", mode = { "n", "x", "o" }, function() vim.cmd("CopilotChatToggle") end, desc = "Toggle Copilot Chat" },
		},
	},
}
