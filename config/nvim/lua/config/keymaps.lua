local mini = require("config.mini")
local pick = mini.pick
local files = mini.files
local bufremove = mini.bufremove
local colorscheme_picker = mini.colorscheme_picker
local snippets = mini.snippets
local flash = require("flash")
local buffer_manager_ui = require("buffer_manager.ui")

local function check_health(targets)
  local cmd = "checkhealth"
  if targets and #targets > 0 then
    cmd = cmd .. " " .. table.concat(targets, " ")
  end
  vim.cmd(cmd)
end

local function pick_filetype()
  local target_buf = vim.api.nvim_get_current_buf()
  local current = vim.bo.filetype
  local filetypes = vim.fn.getcompletion("", "filetype")
  table.sort(filetypes)

  if current ~= "" then
    filetypes = vim.tbl_filter(function(filetype)
      return filetype ~= current
    end, filetypes)
    table.insert(filetypes, 1, current)
  end

  pick.start({
    source = {
      items = filetypes,
      name = current ~= "" and ("Filetypes (" .. current .. ")") or "Filetypes",
      choose = function(item)
        if not item or item == "" then
          return
        end

        if not vim.api.nvim_buf_is_valid(target_buf) then
          vim.notify("Original buffer is no longer available", vim.log.levels.WARN)
          return
        end

        vim.api.nvim_set_option_value("filetype", item, { buf = target_buf })
        vim.notify("Filetype set to " .. item, vim.log.levels.INFO)
      end,
    },
  })
end

local buffer_mappings = {
  delete = {
    char = "<C-d>",
    func = function()
      -- Delete marked buffers if present; otherwise delete the focused one,
      -- then refresh the picker list so removed entries disappear immediately.
      local matches = MiniPick.get_picker_matches()
      if not matches then
        return
      end

      local targets = {}
      if matches.marked and #matches.marked > 0 then
        for _, item in ipairs(matches.marked) do
          if type(item) == "table" and item.bufnr then
            targets[item.bufnr] = true
          end
        end
      elseif matches.current and matches.current.bufnr then
        targets[matches.current.bufnr] = true
      end

      local removed = {}
      for bufnr in pairs(targets) do
        if bufremove.delete(bufnr, true) then
          removed[bufnr] = true
        end
      end

      if next(removed) ~= nil then
        local items = MiniPick.get_picker_items() or {}
        local filtered = vim.tbl_filter(function(item)
          return not (type(item) == "table" and item.bufnr and removed[item.bufnr])
        end, items)
        MiniPick.set_picker_items(filtered, { do_match = true })
      end
    end,
  },
}

vim.keymap.set("n", "<leader>ff", function()
  pick.builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader><leader>", function()
  pick.builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fb", function()
  pick.builtin.buffers(nil, { mappings = buffer_mappings })
end, { desc = "Find buffers" })

vim.keymap.set("n", "<C-b>", function()
  buffer_manager_ui.toggle_quick_menu()
end, { desc = "Open Buffer Manager" })

vim.keymap.set("n", "<leader>fh", function()
  pick.builtin.help()
end, { desc = "Find help" })

vim.keymap.set("n", "<leader>fg", function()
  pick.builtin.grep_live()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fe", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = nil
  end
  files.open(path, false)
end, { desc = "Explore files" })

vim.keymap.set("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = nil
  end
  files.open(path, false)
end, { desc = "Explore files" })

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

vim.keymap.set("n", "<C-q>", "<cmd>qa!<cr>", { desc = "Quit without saving" })

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save buffer" })

vim.keymap.set("n", "<leader>W", "<cmd>wall<cr>", { desc = "Save all buffers" })

vim.keymap.set("n", "<leader>bd", function()
  bufremove.delete(0, true)
end, { desc = "Delete current buffer" })

vim.keymap.set("n", "]b", function()
  buffer_manager_ui.nav_next()
end, { desc = "Next buffer" })

vim.keymap.set("n", "[b", function()
  buffer_manager_ui.nav_prev()
end, { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit current window" })

vim.keymap.set("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle word wrap" })

vim.keymap.set("n", "<leader>fc", colorscheme_picker, { desc = "Pick colorscheme" })

vim.keymap.set("n", "<leader>ft", pick_filetype, { desc = "Pick filetype" })

vim.keymap.set("n", "<leader>hh", function()
  check_health()
end, { desc = "Check all health" })

vim.keymap.set("n", "<leader>hn", function()
  check_health({ "vim.health" })
end, { desc = "Check Nvim health" })

vim.keymap.set("n", "<leader>hp", function()
  check_health({ "vim.provider" })
end, { desc = "Check provider health" })

vim.keymap.set("n", "<leader>hl", function()
  check_health({ "vim.lsp" })
end, { desc = "Check LSP health" })

vim.keymap.set("n", "<leader>hk", function()
  check_health({ "vim.pack" })
end, { desc = "Check vim.pack health" })

vim.keymap.set("n", "<leader>ho", function()
  vim.notify("Opening vim.pack status view", vim.log.levels.INFO)
  vim.pack.update(nil, { offline = true })
end, { desc = "Open vim.pack status" })

vim.keymap.set("n", "<leader>ht", function()
  check_health({ "vim.treesitter" })
end, { desc = "Check Treesitter health" })

vim.keymap.set("n", "<leader>hu", function()
  vim.notify("Updating vim.pack plugins", vim.log.levels.INFO)
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })

vim.keymap.set("n", "<leader>hm", function()
  check_health({ "mason" })
end, { desc = "Check Mason health" })

vim.keymap.set("n", "<leader>ha", function()
  check_health({ "arborist" })
end, { desc = "Check Arborist health" })

vim.keymap.set("n", "U", "u", { desc = "Undo" })

vim.keymap.set("i", "<Tab>", function()
  if snippets.session.get() ~= nil then
    snippets.session.jump("next")
    return ""
  end
  return "<Tab>"
end, { expr = true, desc = "Next snippet stop" })

vim.keymap.set("i", "<S-Tab>", function()
  if snippets.session.get() ~= nil then
    snippets.session.jump("prev")
    return ""
  end
  return "<S-Tab>"
end, { expr = true, desc = "Previous snippet stop" })

vim.keymap.set("i", "<C-y>", function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info().selected == -1 then
      return "<C-n><C-y>"
    end
    return "<C-y>"
  end
  return "<C-y>"
end, { expr = true, desc = "Accept completion or pick first item" })

vim.keymap.set({ "n", "x", "o" }, "s", function()
  flash.jump()
end, { desc = "Flash jump" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  flash.treesitter()
end, { desc = "Flash treesitter" })

vim.keymap.set("o", "r", function()
  flash.remote()
end, { desc = "Flash remote" })

vim.keymap.set({ "o", "x" }, "R", function()
  flash.treesitter_search()
end, { desc = "Flash treesitter search" })

vim.keymap.set("c", "<C-s>", function()
  flash.toggle()
end, { desc = "Toggle Flash search" })
