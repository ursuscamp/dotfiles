local map = function(bufnr, modes, lhs, rhs, desc)
  vim.keymap.set(modes, lhs, rhs, {
    buffer = bufnr,
    desc = desc,
  })
end

local minicompletion = require("config.mini").completion
local lsp_servers = require("config.lsp_servers")
local fzf = require("fzf-lua")

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
  capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(),
    minicompletion.get_lsp_capabilities()),
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
    local miniclue = require("mini.clue")

    -- Let conform.nvim handle gq on LSP-attached buffers.
    vim.bo[bufnr].formatexpr = nil
    vim.bo[bufnr].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    map(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP definition")
    map(bufnr, "n", "gD", vim.lsp.buf.declaration, "LSP declaration")
    map(bufnr, "n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, "LSP hover")
    map(bufnr, "n", "grr", fzf.lsp_references, "LSP references")
    map(bufnr, "n", "gri", fzf.lsp_implementations, "LSP implementations")
    map(bufnr, "n", "grt", fzf.lsp_typedefs, "LSP type definition")
    map(bufnr, "n", "grd", function()
      return fzf.diagnostics_document()
    end, "LSP buffer diagnostics")
    map(bufnr, "n", "grD", function()
      return fzf.diagnostics_workspace()
    end, "LSP workspace diagnostics")
    map(bufnr, "n", "grs", fzf.lsp_document_symbols, "LSP document symbols")
    map(bufnr, "n", "grS", fzf.lsp_workspace_symbols, "LSP workspace symbols")
    map(bufnr, "n", "gO", fzf.lsp_document_symbols, "LSP document symbols")

    -- Keep native LSP actions and let fzf-lua handle selection prompts via
    -- its vim.ui.select integration where needed.
    map(bufnr, { "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP code action")
    map(bufnr, "n", "grn", vim.lsp.buf.rename, "LSP rename")
    map(bufnr, "n", "grx", vim.lsp.codelens.run, "LSP code lens")
    map(bufnr, "n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), {
        bufnr = bufnr,
      })
    end, "Toggle inlay hints")

    map(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map(bufnr, "n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

    miniclue.ensure_buf_triggers(bufnr)
  end,
})

vim.lsp.enable(lsp_servers)
