local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.cursorline = true
opt.expandtab = true
opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.inccommand = "split"
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 8
opt.shiftround = true
opt.shiftwidth = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true
opt.updatetime = 250
opt.wrap = false

opt.list = true
opt.laststatus = 3
opt.foldcolumn = "auto:1"
opt.pumborder = "rounded"
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}
opt.fillchars = {
  -- eob = " ",
  -- fold = " ",
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldinner = " ",
  foldsep = " ",
  -- foldsep = "│",
}

local function set_window_separator_highlight()
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "FloatBorder" })
  if not ok then
    return
  end

  vim.api.nvim_set_hl(0, "WinSeparator", {
    fg = hl.fg,
    bold = true,
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_window_separator_highlight,
})

set_window_separator_highlight()
