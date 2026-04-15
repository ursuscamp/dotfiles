local buffer_manager_icons_ns = vim.api.nvim_create_namespace("BufferManagerIcons")
local buffer_manager_icons_group = vim.api.nvim_create_augroup("BufferManagerIcons", { clear = true })

local function get_buffer_manager_icon_target(line)
  if not line or line == "" then
    return nil
  end

  local target = vim.trim(line)
  if target == "" then
    return nil
  end

  target = target:gsub("^%d+|", "")
  target = target:gsub("%s+%b()$", "")

  return target
end

local function render_buffer_manager_icons(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, buffer_manager_icons_ns, 0, -1)

  if not _G.MiniIcons then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then
    return
  end

  for idx, line in ipairs(lines) do
    local target = get_buffer_manager_icon_target(line)
    if target == nil then
      goto continue
    end

    local icon, hl
    if vim.startswith(target, "term:") or vim.startswith(target, "term://") then
      icon, hl = MiniIcons.get("filetype", "terminal")
    else
      icon, hl = MiniIcons.get("file", target)
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

    ::continue::
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

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
      group = buffer_manager_icons_group,
      buffer = ev.buf,
      callback = function()
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            render_buffer_manager_icons(ev.buf)
          end
        end)
      end,
    })

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
