local mini = require("config.mini")
local files = mini.files
local bufremove = mini.bufremove
local colorscheme_picker = require("config.fzf").colorscheme_picker
local snippets = mini.snippets
local flash = require("flash")
local buffer_manager_ui = require("buffer_manager.ui")
local fzf = require("fzf-lua")

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

  fzf.filetypes({
    prompt = current ~= "" and ("Filetypes (" .. current .. ")❯ ") or "Filetypes❯ ",
    actions = {
      ["enter"] = function(selected)
        if not selected or not selected[1] then
          return
        end

        if not vim.api.nvim_buf_is_valid(target_buf) then
          vim.notify("Original buffer is no longer available", vim.log.levels.WARN)
          return
        end

        local filetype = selected[1]:match("[^%s]+$")
        if not filetype or filetype == "" then
          return
        end

        vim.api.nvim_set_option_value("filetype", filetype, { buf = target_buf })
        vim.notify("Filetype set to " .. filetype, vim.log.levels.INFO)
      end,
    },
  })
end

vim.keymap.set("n", "<leader>ff", function()
  fzf.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader><leader>", function()
  fzf.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fb", function()
  fzf.buffers()
end, { desc = "Find buffers" })

vim.keymap.set("n", "<C-b>", function()
  buffer_manager_ui.toggle_quick_menu()
end, { desc = "Open Buffer Manager" })

vim.keymap.set("n", "<leader>fh", function()
  fzf.helptags()
end, { desc = "Find help" })

vim.keymap.set("n", "<leader>fk", function()
  fzf.keymaps()
end, { desc = "Find keymaps" })

vim.keymap.set("n", "<leader>fg", function()
  fzf.live_grep()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fl", function()
  fzf.lsp_finder()
end, { desc = "LSP finder" })

vim.keymap.set("n", "<leader>fr", function()
  fzf.resume()
end, { desc = "Resume picker" })

vim.keymap.set("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = nil
  end
  files.open(path, false)
end, { desc = "Explore files" })

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

vim.keymap.set("n", "<C-q>", "<cmd>qa!<cr>", { desc = "Quit without saving" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save buffer" })

vim.keymap.set("n", "<leader>W", "<cmd>wall<cr>", { desc = "Save all buffers" })

vim.keymap.set("n", "<leader>fm", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontally" })

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertically" })

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

vim.keymap.set("n", "<leader>hf", function()
  check_health({ "fzf_lua" })
end, { desc = "Check fzf-lua health" })

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
