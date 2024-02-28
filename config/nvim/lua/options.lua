-- These have pulled from kickstart.nvim
--

-- Set folding to indent, start all unfolded
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = false

vim.opt.relativenumber = true

-- System clipboard
vim.opt.clipboard = 'unnamedplus'
--
-- -- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- -- Sets how neovim will display certain whitespace in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ' }
--
-- -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.diagnostic.config({
	float = {
		border = "rounded"
	}
})
