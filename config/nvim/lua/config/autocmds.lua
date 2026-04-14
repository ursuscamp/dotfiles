local buffer_manager_icons_ns = vim.api.nvim_create_namespace("BufferManagerIcons")

local function render_buffer_manager_icons(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, buffer_manager_icons_ns, 0, -1)

  if not _G.MiniIcons then
    return
  end

  local ok, buffer_manager = pcall(require, "buffer_manager")
  if not ok then
    return
  end

  for idx, mark in ipairs(buffer_manager.marks) do
    local icon, hl
    if vim.startswith(mark.buf_name, "term://") then
      icon, hl = MiniIcons.get("filetype", "terminal")
    else
      icon, hl = MiniIcons.get("file", mark.buf_name)
    end

    if icon and icon ~= "" then
      vim.api.nvim_buf_set_extmark(bufnr, buffer_manager_icons_ns, idx - 1, 0, {
        virt_text = {
          { " ", "Normal" },
          { icon, hl },
          { " ", "Normal" },
        },
        virt_text_pos = "inline",
      })
    end
  end
end

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
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        render_buffer_manager_icons(ev.buf)
      end
    end)

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
