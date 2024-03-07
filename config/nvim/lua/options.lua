-- These have pulled from kickstart.nvim
--

-- Set folding to indent, start all unfolded
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
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

-- Read jinja files as html for syntax highlight purposes
vim.filetype.add({
	pattern = {
		[".*.jinja"] = "html",
	}
})

-- Outputing OSC 7 whenever the directory is changed.
-- This way wezterm will detect when the nvim directory is changed and the next terminal split
-- will open in the current directory.
vim.api.nvim_create_augroup("OSC7", { clear = true });
vim.api.nvim_create_autocmd({ 'DirChanged', 'BufEnter', 'SessionLoadPost' }, {
	pattern = { '*' },
	callback = function()
		io.write("\027]7;file://" .. vim.fn.getcwd() .. "\027\\")
	end
})
