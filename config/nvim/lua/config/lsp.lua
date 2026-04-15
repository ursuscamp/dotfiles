local map = function(bufnr, modes, lhs, rhs, desc)
  vim.keymap.set(modes, lhs, rhs, {
    buffer = bufnr,
    desc = desc,
  })
end

local minicompletion = require("config.mini").completion
local miniextra = require("config.mini").extra
local lsp_servers = require("config.lsp_servers")

vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "if_many",
  },
  severity_sort = true,
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
})

vim.lsp.config("*", {
  capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), minicompletion.get_lsp_capabilities()),
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    vim.bo[bufnr].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

    local lsp_picker = function(scope, opts)
      return function()
        return miniextra.pickers.lsp(vim.tbl_deep_extend("force", { scope = scope }, opts or {}))
      end
    end

    -- Use MiniExtra pickers where available so LSP navigation lands in MiniPick
    -- instead of the default quickfix / location list flow.
    map(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP definition")
    map(bufnr, "n", "gD", vim.lsp.buf.declaration, "LSP declaration")
    map(bufnr, "n", "grr", lsp_picker("references"), "LSP references")
    map(bufnr, "n", "gri", lsp_picker("implementation"), "LSP implementations")
    map(bufnr, "n", "grt", lsp_picker("type_definition"), "LSP type definition")
    map(bufnr, "n", "grd", function()
      return miniextra.pickers.diagnostic({ scope = "current" })
    end, "LSP buffer diagnostics")
    map(bufnr, "n", "grD", function()
      return miniextra.pickers.diagnostic({ scope = "all" })
    end, "LSP workspace diagnostics")
    map(bufnr, "n", "grs", lsp_picker("document_symbol"), "LSP document symbols")
    map(bufnr, "n", "grS", lsp_picker("workspace_symbol"), "LSP workspace symbols")
    map(bufnr, "n", "gO", lsp_picker("document_symbol"), "LSP document symbols")

    -- These don't have MiniExtra picker equivalents, so keep the native LSP
    -- actions and let mini.pick handle any selection prompts via vim.ui.select.
    map(bufnr, { "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP code action")
    map(bufnr, "n", "grn", vim.lsp.buf.rename, "LSP rename")
    map(bufnr, "n", "grx", vim.lsp.codelens.run, "LSP code lens")

    map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map(bufnr, { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map(bufnr, "n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

vim.lsp.enable(lsp_servers)
