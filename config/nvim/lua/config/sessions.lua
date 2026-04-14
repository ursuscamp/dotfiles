local minisessions = require("mini.sessions")

minisessions.setup({
  autoread = false,
  autowrite = true,
  file = "",
  verbose = {
    read = false,
    write = false,
    delete = true,
  },
})

local session_group = vim.api.nvim_create_augroup("NvimGlobalSessions", { clear = true })

local function normalized_cwd()
  return vim.fs.normalize(vim.fn.getcwd())
end

local function session_name_from_cwd()
  return normalized_cwd():gsub("[/\\:]", "%%")
end

local function should_manage_session()
  local cwd = normalized_cwd()
  local home = vim.fs.normalize(vim.uv.os_homedir())
  local temp = vim.fs.normalize(vim.fn.stdpath("run"))

  if cwd == home or cwd == temp or vim.startswith(cwd, temp .. "/") then
    return false
  end

  return true
end

local function refresh_session_buffer_filetypes()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_loaded(bufnr) then
      goto continue
    end

    if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype ~= "" then
      goto continue
    end

    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
      goto continue
    end

    local filetype = vim.filetype.match({ buf = bufnr, filename = name })
    if filetype ~= nil and filetype ~= "" then
      vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    end

    ::continue::
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = session_group,
  callback = function()
    if vim.fn.argc() > 0 or not should_manage_session() then
      return
    end

    local session_name = session_name_from_cwd()
    if MiniSessions.detected[session_name] ~= nil then
      MiniSessions.read(session_name, { force = true })
    end
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = session_group,
  callback = refresh_session_buffer_filetypes,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = session_group,
  callback = function()
    if not should_manage_session() then
      return
    end

    pcall(MiniSessions.write, session_name_from_cwd(), { force = true })
  end,
})
