MiniDeps.add({ source = "williamboman/mason.nvim" })
MiniDeps.add({ source = "williamboman/mason-lspconfig.nvim" })
MiniDeps.add({ source = "neovim/nvim-lspconfig" })

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "tsserver", "rust_analyzer" },
})

require("lspconfig").rust_analyzer.setup({})
require("lspconfig").tsserver.setup({})
require("lspconfig").lua_ls.setup({})
require("lspconfig").emmet_ls.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").solargraph.setup({})

