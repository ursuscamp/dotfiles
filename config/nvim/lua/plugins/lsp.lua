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

return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"folke/neodev.nvim",
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-cmdline',
		'hrsh7th/nvim-cmp',
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
		'lvimuser/lsp-inlayhints.nvim',
		'rafamadriz/friendly-snippets',
	},
	config = function()
		-- LSP
		require('neodev').setup()

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


		local ih = require('lsp-inlayhints')
		ih.setup()
		local lsp = require('lspconfig')
		local capabilities = require('cmp_nvim_lsp').default_capabilities()
		for server, config in pairs(MASON_TOOLS["servers"]) do
			if config ~= nil then
				local c = {
					on_attach = function(client, bufnr)
						ih.on_attach(client, bufnr)
					end,
					capabilities = capabilities,
					settings = config,
				}
				lsp[server].setup(c)
			end
		end

		-- Completion
		local cmp = require('cmp')
		local luasnip = require('luasnip')

		cmp.setup({
			snippet = {
				-- REQUIRED - you must specify a snippet engine
				expand = function(args)
					require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				['<C-b>'] = cmp.mapping.scroll_docs(-4),
				['<C-f>'] = cmp.mapping.scroll_docs(4),
				['<C-Space>'] = cmp.mapping.complete(),
				['<C-e>'] = cmp.mapping.abort(),
				['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = 'nvim_lsp' },
				{ name = 'luasnip' }, -- For luasnip users.
			}, {
				{ name = 'buffer' },
			})
		})

		-- Setup friendly-snippets
		require("luasnip.loaders.from_vscode").lazy_load()
	end
}
