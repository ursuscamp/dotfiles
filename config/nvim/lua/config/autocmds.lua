vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldlevelstart = 99
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "buffer_manager",
  callback = function(ev)
    vim.keymap.set("n", "J", ":m .+1<CR>==", {
      buffer = ev.buf,
      desc = "Move buffer entry down",
    })

    vim.keymap.set("n", "K", ":m .-2<CR>==", {
      buffer = ev.buf,
      desc = "Move buffer entry up",
    })

    vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", {
      buffer = ev.buf,
      desc = "Move buffer entries down",
    })

    vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", {
      buffer = ev.buf,
      desc = "Move buffer entries up",
    })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
