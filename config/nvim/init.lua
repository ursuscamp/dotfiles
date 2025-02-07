require("config.lazy")

-- Setup mini.nvim that I wish to use
require("mini.basics").setup({
	options = {
		basic = true,
		extra_ui = true,
	},
	mappings = {
		windows = true,
	},
})
require("mini.pairs").setup()
require("mini.surround").setup({
	mappings = {
		add = "gsa", -- Add surrounding in Normal and Visual modes
		delete = "gsd", -- Delete surrounding
		find = "gsf", -- Find surrounding (to the right)
		find_left = "gsF", -- Find surrounding (to the left)
		highlight = "gsh", -- Highlight surrounding
		replace = "gsr", -- Replace surrounding
		update_n_lines = "gsn", -- Update `n_lines`

		suffix_last = "l", -- Suffix to search with "prev" method
		suffix_next = "n", -- Suffix to search with "next" method
	},
})
require("mini.bufremove").setup()
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
require("mini.ai").setup()

-- Basic options
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10
vim.g.copilot_cmp = true

local function f(c)
	return function()
		vim.cmd(c)
	end
end

-- Keymaps
vim.keymap.set({ "i" }, "jk", "<esc>")
vim.keymap.set({ "n" }, "<leader>gg", function()
	require("snacks").lazygit()
end, { desc = "LazyGit" })
vim.keymap.set({ "n", "x", "v", "i" }, "<C-q>", function()
	vim.cmd("quitall!")
end)
vim.keymap.set({ "n" }, "U", function()
	vim.cmd("redo")
end)
require("snacks.toggle").inlay_hints():map("<leader>uh")
require("snacks.toggle").diagnostics():map("<leader>ud")
require('snacks.toggle').option("spell", { name = "Spelling" }):map("<leader>us")
require('snacks.toggle').option("wrap", { name = "Wrap" }):map("<leader>uw")
require('snacks.toggle').option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
require('snacks.toggle').diagnostics():map("<leader>ud")
require('snacks.toggle').line_number():map("<leader>ul")
require('snacks.toggle').option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map(
	    "<leader>uc")
require('snacks.toggle').treesitter():map("<leader>uT")
require('snacks.toggle').option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
require('snacks.toggle').inlay_hints():map("<leader>uh")
require('snacks.toggle').indent():map("<leader>ug")
require('snacks.toggle').dim():map("<leader>uD")
require('snacks.toggle').new({
	id = "compilot_cmp",
	name = "Copilot completion",
	get = function()
		return vim.g.copilot_cmp
	end,
	set = function(value)
		vim.g.copilot_cmp = value
	end,
}):map("<leader>aC")

vim.keymap.set("n", "<leader>bd", MiniBufremove.delete, { desc = "Delete buffer" })
vim.keymap.set("n", "H", f("BufferLineCyclePrev"), { desc = "Previous buffer" })
vim.keymap.set("n", "L", f("BufferLineCycleNext"), { desc = "Next buffer" })
vim.keymap.set("n", "[B", f("BufferLineMovePrev"), { desc = "Move buffer left" })
vim.keymap.set("n", "]B", f("BufferLineMoveNext"), { desc = "Move buffer right" })
vim.keymap.set("n", "<c-f>", f("BufferLinePick"), { desc = "Move buffer right" })
vim.keymap.set("n", "<leader>bp", f("BufferLineTogglePin"), { desc = "Toggle pin" })
vim.keymap.set("n", "<leader>bc", f("BufferLineCloseOthers"), { desc = "Close other buffers" })
vim.keymap.set("n", "<leader>br", f("BufferLineCloseRight"), { desc = "Close to right" })
vim.keymap.set("n", "<leader>bl", f("BufferLineCloseLeft"), { desc = "Close to left" })

vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set({ "n", "v" }, "<leader>cr", vim.lsp.buf.rename, { desc = "Rename under cursor" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Next warning" })
vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Previous warning" })

vim.keymap.set("n", "<leader>am", vim.cmd.CopilotChatModels, { desc = 'Change Copilot Model' })
