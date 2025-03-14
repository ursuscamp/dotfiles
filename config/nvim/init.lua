-- Basic options
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10
vim.opt.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.g.copilot_cmp = true
vim.g.diff_overlay = false
vim.g.autoformat = true

-- Required setup for nvim-ufo
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

if vim.g.vscode then
	return
end

if vim.uv.os_gethostname():find("rbreen") then
	vim.g.work_computer = true
end



require("config.lazy")


-- Keymaps
vim.keymap.set({ "i" }, "jk", "<esc>")
vim.keymap.set({ "n", "x", "v", "i" }, "<C-q>", function() vim.cmd("quitall!") end)
vim.keymap.set({ "n" }, "U", vim.cmd.redo)
vim.keymap.set("n", "<leader>|", vim.cmd.vsplit, { desc = "Vertical split" })
vim.keymap.set("n", "<leader>\\", vim.cmd.split, { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>q", vim.cmd.quit, { desc = "Quit window" })
vim.keymap.set("n", "<leader>L", vim.cmd.Lazy, { desc = "Lazy" })
vim.keymap.set("n", "<leader>w", vim.cmd.write, { desc = "Write" })
vim.keymap.set("n", "<leader>W", vim.cmd.wa, { desc = "Write all" })


vim.keymap.set("n", 'gt', vim.lsp.buf.type_definition, { desc = 'Goto type definition' })
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

vim.cmd.cnoreabbrev("cc", "CodeCompanion")
vim.cmd.cnoreabbrev("ccc", "CodeCompanionChat")
