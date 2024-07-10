local function open_cwd()
	local oil = require('oil')
	oil.open(vim.fn.getcwd())
end

return {
	'stevearc/oil.nvim',
	cmd = "Oil",
	keys = {
		{ '<leader>e', '<cmd>Oil --float<CR>', desc = "Open file explorer (buffer)" },
		{ '<leader>E', open_cwd,               desc = "Open file explorer (cwd)" },
	},
	opts = {
		default_file_explorer = true,
		skip_confirm_for_simple_edits = true,
		view_options = {
			show_hidden = true,
			is_always_hidden = function(name, _)
				return name == ".." or name == ".git"
			end,
		}
	},
}
