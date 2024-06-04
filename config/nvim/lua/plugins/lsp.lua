local MASON_TOOLS = {
	-- LSP servers that will be installed and configured by mason-lspconfig
	servers = {
		lua_ls = {},
		rust_analyzer = {
			["rust-analyzer"] = {
				checkOnSave = {
					command = "clippy",
				},
			},
		},
		html = {},
		tsserver = {},
		marksman = {},
		pyright = {},
		vuels = {},
		solargraph = {},

	},

	-- Non-LSP tools that can be installed by mason
	tools = {
		"prettier",
	}
}

-- Border for hover
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

return {
	"williamboman/mason.nvim",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "Mason", "LspInstall", "LspInfo", "LspUninstall" },
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		'hrsh7th/cmp-nvim-lsp',
	},
	config = function()
		-- LSP
		require('mason').setup()
		require('mason-lspconfig').setup({
			ensure_installed = vim.tbl_keys(MASON_TOOLS["servers"]),
		})

		-- Install missing tools
		for _, tool in ipairs(MASON_TOOLS["tools"]) do
			if not require('mason-registry').is_installed(tool) then
				vim.cmd('MasonInstall ' .. tool)
			end
		end


		vim.lsp.inlay_hint.enable()
		local lsp = require('lspconfig')
		local capabilities = require('cmp_nvim_lsp').default_capabilities()
		for server, config in pairs(MASON_TOOLS["servers"]) do
			if config ~= nil then
				local c = {
					on_attach = function(client, bufnr)
						-- Inlay hints used to be here. Thanks nvim 0.10!
					end,
					capabilities = capabilities,
					settings = config,
				}
				lsp[server].setup(c)
			end
		end
	end
}
