vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/catppuccin/nvim",
  "https://github.com/arborist-ts/arborist.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/kdheepak/lazygit.nvim",
}, { load = true })

vim.cmd.colorscheme("catppuccin")

require("arborist").setup({
  prefer_wasm = false,
})

require("flash").setup({})
