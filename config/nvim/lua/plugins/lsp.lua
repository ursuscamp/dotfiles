return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
		opts = {
			servers = {
				lua_ls = {},
				rust_analyzer = {},
				ts_ls = {},
				pyright = {},
				marksman = {},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				-- passing config.capabilities to blink.cmp merges with the capabilities in your
				-- `opts[server].capabilities, if you've defined it
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function()
					vim.lsp.inlay_hint.enable(true, { 0 })
				end,
			})
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "Snacks", words = { "Snacks" } },
			},
		},
	},
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "markdown", "lazydev" },
				providers = {
					markdown = {
						name = "RenderMarkdown",
						module = "render-markdown.integ.blink",
						fallbacks = { "lsp" },
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
			completion = {
				menu = {
					border = "rounded",
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 0,
					window = {
						border = "rounded",
					},
				},
				ghost_text = {
					enabled = true,
				},
			},
			signature = { enabled = true, window = { show_documentation = true, border = "rounded" } },
		},
		opts_extend = { "sources.default" },
	},
}
