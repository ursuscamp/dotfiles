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
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							-- checkOnSave = {
							-- 	command = "clippy",
							-- },
							completion = {
								postfix = { enable = true },
								termSearch = { enable = true },
							},
						},
					},
				},
				ts_ls = {},
				-- pyright = {},
				pylsp = {},
				marksman = {},
				ruby_lsp = {
					init_options = {
						formatter = "standard",
						linters = { "standard" },
					},
				},
			},
		},
		config = function(_, opts)
			for server, config in pairs(opts.servers) do
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
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
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "Snacks", words = { "Snacks" } },
			},
		},
	},
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets", "giuxtaposition/blink-cmp-copilot" },
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
				kind_icons = {
					Copilot = "",
				},
			},
			sources = {
				default = function()
					if vim.g.copilot_cmp then
						return { "lsp", "path", "snippets", "buffer", "markdown", "lazydev", "copilot" }
					else
						return { "lsp", "path", "snippets", "buffer", "markdown", "lazydev" }
					end
				end,
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
					copilot = {
						name = "copilot",
						module = "blink-cmp-copilot",
						score_offset = 100,
						async = true,
						transform_items = function(_, items)
							local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
							local kind_idx = #CompletionItemKind + 1
							CompletionItemKind[kind_idx] = "Copilot"
							for _, item in ipairs(items) do
								item.kind = kind_idx
							end
							return items
						end,
					},
				},
			},
			completion = {
				menu = {
					border = "rounded",
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", gap = 1 },
							{ "kind" },
						},
					},
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
