-- Load this plugin only on my work machine
local config = {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	dependencies = {
		{ "github/copilot.vim" },
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		require("CopilotChat").setup({
			auto_insert_mode = true,
			mappings = {
				reset = {
					normal = "<C-r>",
					insert = "<C-r>",
				},
				complete = {
					normal = "<C-g>",
					insert = "<C-g>",
				},
			},
		})
		vim.cmd(":Copilot enable")

		vim.keymap.set({ 'n', 'v' }, '<leader>gcc', '<cmd>CopilotChatToggle<CR>',
			{ desc = "Toggle Copilot Chat" })
		vim.keymap.set({ 'n', 'v' }, '<leader>gce', '<cmd>Copilot enable<CR>',
			{ desc = "Enable Copilot suggestions" })
		vim.keymap.set({ 'n', 'v' }, '<leader>gcd', '<cmd>Copilot disable<CR>',
			{ desc = "Disable Copilot suggestions" })
	end,
	lazy = true
}

if vim.fn.getenv('USER') == 'rbreen' then
	config.event = 'VeryLazy'
end

return config
