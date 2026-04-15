local mermaid_group = vim.api.nvim_create_augroup("MermaidPreview", { clear = true })

local function table_slice(values, first, last)
  local result = {}
  if first > last then
    return result
  end

  for idx = first, last do
    result[#result + 1] = values[idx]
  end

  return result
end

local function trim_blank_edges(lines)
  local first = 1
  local last = #lines

  while first <= last and lines[first]:match("^%s*$") do
    first = first + 1
  end

  while last >= first and lines[last]:match("^%s*$") do
    last = last - 1
  end

  return table_slice(lines, first, last)
end

local function strip_wrapping_fences(lines)
  lines = trim_blank_edges(lines)

  if #lines < 2 then
    return lines
  end

  local first = lines[1]
  local last = lines[#lines]

  if not first:match("^%s*```%s*[%w%._%-%+]*") then
    return lines
  end

  if not last:match("^%s*```%s*$") then
    return lines
  end

  return table_slice(lines, 2, #lines - 1)
end

local function is_mermaid_file(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  return name:match("%.mmd$") ~= nil or name:match("%.mermaid$") ~= nil
end

local function fence_info(line)
  local lang = line:match("^%s*```%s*([%w%._%-%+]+)")
  if lang ~= nil then
    return "open", lang:lower()
  end

  if line:match("^%s*```%s*$") then
    return "close"
  end

  return nil
end

local function mermaid_block_at_cursor(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local active_lang
  local block_start

  for row = 1, cursor_row do
    local kind, lang = fence_info(lines[row])
    if kind == "open" then
      active_lang = lang
      block_start = row
    elseif kind == "close" then
      active_lang = nil
      block_start = nil
    end
  end

  if active_lang ~= "mermaid" or not block_start then
    return nil
  end

  local block_end
  for row = cursor_row + 1, #lines do
    local kind = fence_info(lines[row])
    if kind == "close" then
      block_end = row
      break
    end
  end

  if not block_end then
    return nil
  end

  return table_slice(lines, block_start + 1, block_end - 1)
end

local function selected_lines(bufnr, line1, line2)
  return vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
end

local function source_for_request(bufnr, opts)
  if opts.range > 0 then
    return strip_wrapping_fences(selected_lines(bufnr, opts.line1, opts.line2))
  end

  if is_mermaid_file(bufnr) then
    return strip_wrapping_fences(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end

  return mermaid_block_at_cursor(bufnr)
end

local function escape_html(text)
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  return text
end

local function preview_html(source)
  local escaped = escape_html(table.concat(source, "\n"))

  return table.concat({
    "<!doctype html>",
    "<html lang=\"en\">",
    "<head>",
    "  <meta charset=\"utf-8\">",
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    "  <title>Mermaid Preview</title>",
    "  <style>",
    "    :root { color-scheme: light; }",
    "    body { margin: 0; padding: 24px; font-family: ui-sans-serif, system-ui, sans-serif; background: #f6f3ee; }",
    "    .frame { background: white; border: 1px solid #ddd3c9; border-radius: 16px; padding: 24px; box-shadow: 0 18px 50px rgba(35, 24, 14, 0.10); }",
    "    .hint { margin: 0 0 16px; color: #6a6158; font-size: 14px; }",
    "    .mermaid { display: flex; justify-content: center; overflow: auto; }",
    "  </style>",
    "  <script src=\"https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js\"></script>",
    "</head>",
    "<body>",
    "  <div class=\"frame\">",
    "    <p class=\"hint\">Local Mermaid preview</p>",
    "    <div class=\"mermaid\">",
    escaped,
    "    </div>",
    "  </div>",
    "  <script>",
    "    mermaid.initialize({",
    "      startOnLoad: true,",
    "      securityLevel: 'loose',",
    "      theme: 'neutral',",
    "    });",
    "  </script>",
    "</body>",
    "</html>",
  }, "\n")
end

local function open_in_browser(target, label)
  local cmd, err = vim.ui.open(target)
  if not cmd then
    vim.notify(("Failed to open %s: %s"):format(label, err or "unknown error"), vim.log.levels.ERROR)
  end
end

local function open_local_preview(source)
  local path = vim.fn.tempname() .. ".html"
  local html = preview_html(source)
  vim.fn.writefile(vim.split(html, "\n", { plain = true }), path)
  open_in_browser(path, "Mermaid preview")
end

local function mermaid_live_url(source)
  local payload = vim.json.encode({
    code = table.concat(source, "\n"),
    mermaid = {
      theme = "default",
    },
    autoSync = true,
    updateDiagram = false,
    editorMode = "code",
  })

  local script = [[
import base64
import sys
import zlib

data = sys.stdin.read().encode("utf-8")
encoded = base64.urlsafe_b64encode(zlib.compress(data, 9)).decode("ascii").rstrip("=")
sys.stdout.write("https://mermaid.live/edit#pako:" + encoded)
]]

  local ok, result = pcall(function()
    return vim.system({ "python3", "-c", script }, { text = true, stdin = payload }):wait()
  end)

  if not ok then
    return nil, "python3 is required to build Mermaid Live URLs"
  end

  if result.code ~= 0 then
    return nil, (result.stderr and result.stderr ~= "" and result.stderr) or "failed to build Mermaid Live URL"
  end

  return vim.trim(result.stdout)
end

local function open_mermaid_live(source)
  local url, err = mermaid_live_url(source)
  if not url then
    vim.notify(("Mermaid Live URL unavailable, using local preview: %s"):format(err or "unknown error"), vim.log.levels.WARN)
    return open_local_preview(source)
  end

  open_in_browser(url, "Mermaid Live Editor")
end

local function open_mermaid_source(open_handler, opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local source = source_for_request(bufnr, opts)

  if not source or #source == 0 then
    vim.notify("No Mermaid source found", vim.log.levels.WARN)
    return
  end

  open_handler(source)
end

vim.api.nvim_create_user_command("MermaidLive", function(opts)
  open_mermaid_source(open_mermaid_live, opts)
end, {
  range = true,
  desc = "Open Mermaid in mermaid.live",
})

vim.api.nvim_create_user_command("MermaidPreview", function(opts)
  open_mermaid_source(open_local_preview, opts)
end, {
  range = true,
  desc = "Open Mermaid in a local HTML preview",
})

vim.api.nvim_create_autocmd("FileType", {
  group = mermaid_group,
  pattern = { "markdown", "mdx", "rmd", "quarto", "mermaid" },
  callback = function(ev)
    vim.keymap.set("n", "<leader>ml", "<cmd>MermaidLive<cr>", {
      buffer = ev.buf,
      desc = "Open Mermaid in browser",
    })

    vim.keymap.set("x", "<leader>ml", ":MermaidLive<cr>", {
      buffer = ev.buf,
      desc = "Open Mermaid selection in browser",
    })

    vim.keymap.set("n", "<leader>mp", "<cmd>MermaidPreview<cr>", {
      buffer = ev.buf,
      desc = "Open Mermaid local preview",
    })

    if _G.MiniClue ~= nil then
      MiniClue.ensure_buf_triggers(ev.buf)
    end
  end,
})
