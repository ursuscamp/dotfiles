MiniDeps.add({ source = "williamboman/mason.nvim" })
MiniDeps.add({ source = "williamboman/mason-lspconfig.nvim" })
MiniDeps.add({ source = "neovim/nvim-lspconfig" })

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "tsserver", "rust_analyzer" },
})

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
	rust_analyzer = {},
	tsserver = {},
	lua_ls = {},
	emmet_ls = {},
	pyright = {},
	solargraph = {},
}

for server, opts in pairs(servers) do
	opts["capabilities"] = capabilities
	lspconfig[server].setup(opts)
end
