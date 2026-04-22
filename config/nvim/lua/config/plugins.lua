vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/catppuccin/nvim",
  "https://github.com/arborist-ts/arborist.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/j-morano/buffer_manager.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/kdheepak/lazygit.nvim",
  { src = "https://github.com/folke/lazydev.nvim", name = "lazydev" },
}, {
  load = function(plugin)
    if plugin.spec.name == "lazydev" then
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        once = true,
        callback = function()
          vim.cmd.packadd("lazydev")
          require("config.lazydev").setup()
        end,
      })
      return
    end

    vim.cmd.packadd(plugin.spec.name)
  end,
})

vim.cmd.colorscheme("catppuccin")

require("arborist").setup({
  prefer_wasm = false,
})

require("buffer_manager").setup({
  use_shortcuts = false,
})

require("flash").setup({})
