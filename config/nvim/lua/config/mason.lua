local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lsp_servers = require("config.lsp_servers")

mason.setup()

mason_lspconfig.setup({
  automatic_enable = false,
  ensure_installed = lsp_servers,
})
