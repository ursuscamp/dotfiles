MiniDeps.add({ source = "folke/neodev.nvim" })
MiniDeps.add({ source = "williamboman/mason.nvim" })
MiniDeps.add({ source = "williamboman/mason-lspconfig.nvim" })
MiniDeps.add({ source = "neovim/nvim-lspconfig" })

MiniDeps.later(function()
	require("neodev").setup()
	require("mason").setup()
	require("mason-lspconfig").setup({
		automatic_installation = true,
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
		marksman = {},
	}

	for server, opts in pairs(servers) do
		opts["capabilities"] = capabilities
		lspconfig[server].setup(opts)
	end
end)
