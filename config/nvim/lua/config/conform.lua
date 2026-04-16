local conform = require("conform")

local prettier_filetypes = {
  css = { "prettierd", "prettier", stop_after_first = true },
  html = { "prettierd", "prettier", stop_after_first = true },
  javascript = { "prettierd", "prettier", stop_after_first = true },
  javascriptreact = { "prettierd", "prettier", stop_after_first = true },
  json = { "prettierd", "prettier", stop_after_first = true },
  jsonc = { "prettierd", "prettier", stop_after_first = true },
  less = { "prettierd", "prettier", stop_after_first = true },
  markdown = { "prettierd", "prettier", stop_after_first = true },
  scss = { "prettierd", "prettier", stop_after_first = true },
  typescript = { "prettierd", "prettier", stop_after_first = true },
  typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  yaml = { "prettierd", "prettier", stop_after_first = true },
  yml = { "prettierd", "prettier", stop_after_first = true },
}

conform.setup({
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 1000,
  },
  formatters_by_ft = vim.tbl_extend("force", {
    bash = { "shfmt" },
    fish = { "fish_indent" },
    go = { "goimports", "gofmt" },
    lua = { "stylua" },
    python = { "isort", "black" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    toml = { "taplo" },
    zsh = { "shfmt" },
  }, prettier_filetypes),
  notify_no_formatters = true,
  notify_on_error = true,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
