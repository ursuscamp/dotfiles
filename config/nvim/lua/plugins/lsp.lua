MiniDeps.add({ source = "folke/neodev.nvim" })
MiniDeps.add({ source = "williamboman/mason.nvim" })
MiniDeps.add({ source = "williamboman/mason-lspconfig.nvim" })
MiniDeps.add({ source = "neovim/nvim-lspconfig" })
MiniDeps.add({ source = "lvimuser/lsp-inlayhints.nvim" })

MiniDeps.later(function()
	require("neodev").setup()
	require("mason").setup()
	require("mason-lspconfig").setup({
		automatic_installation = true,
		ensure_installed = { "lua_ls", "tsserver", "rust_analyzer" },
	})
	require("lsp-inlayhints").setup()

	local lspconfig = require("lspconfig")
	local capabilities = require('cmp_nvim_lsp').default_capabilities()

	local servers = {
		rust_analyzer = {
			settings = {
				["rust-analyzer"] = {
					checkOnSave = {
						command = "clippy"
					}
				}
			}
		},
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

	vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
	vim.api.nvim_create_autocmd("LspAttach", {
		group = "LspAttach_inlayhints",
		callback = function(args)
			if not (args.data and args.data.client_id) then
				return
			end

			local bufnr = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			require("lsp-inlayhints").on_attach(client, bufnr)
		end,
	})
end)
