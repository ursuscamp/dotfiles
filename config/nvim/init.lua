vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-------------------
---- Plugins
-------------------

require('lazy').setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { 'folke/which-key.nvim', opts = {} },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "rust" },
          sync_install = false,
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
     dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },

  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    }
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'}
    },
  },
  {'lvimuser/lsp-inlayhints.nvim', opts = {} },
  -- {
  --   "folke/trouble.nvim",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   opts = {
  --    -- your configuration comes here
  --    -- or leave it empty to use the default settings
  --    -- refer to the configuration section below
  --   },
  -- },
  { 'stevearc/conform.nvim'  },
  { 'j-hui/fidget.nvim', opts = {} },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
})

-------------------
---- Options
-------------------

vim.cmd.colorscheme 'catppuccin-macchiato'


vim.opt.hlsearch = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.termguicolors = true

-------------------
---- Setups
-------------------

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_previous",
        ["<C-k>"] = "move_selection_next",
        ["<C-h>"] = "which_key",
      }
    },
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
  }
})
require('telescope').load_extension('fzf')

require('bufferline').setup({
  options = {
    diagnostics = "nvim_lsp",
    offsets = {
      { filetype = "neo-tree" },
    },
  }
})


require('conform').setup({
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})


-- LSP stuff
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
  require('lsp-inlayhints').on_attach(client, bufnr)
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { "rust_analyzer", "lua_ls", "tsserver", "html" },
  handlers = {
    lsp_zero.default_setup,
  },
})

vim.diagnostic.config()

-------------------
---- Keymaps
-------------------
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Write file" })
vim.keymap.set('n', '<C-q>', ':qa<CR>', { desc = "Quit" } )
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move down window" })
vim.keymap.set('n', '<C-k>', '<C-k>h', { desc = "Move up window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move right window" })
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "N[e]otree" } )

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Open buffers" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find help" })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Old files" })
vim.keymap.set('n', '<leader>fc', builtin.colorscheme, { desc = "Colorschemes" })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set('n', '<leader>fy', builtin.filetypes, { desc = "Filetypes" })


vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = "References" })
vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set('n', '<leader>lS', builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set('n', '<leader>ld', ':Telescope diagnostics bufnr=0<CR>', { desc = "Buffer diagnostics" })
vim.keymap.set('n', '<leader>lD', builtin.diagnostics, { desc = "Workspace diagnostics" })

vim.keymap.set('n', ']b', ':BufferLineCycleNext<CR>', { desc =  "Next buffer" })
vim.keymap.set('n', '[b', ':BufferLineCyclePrev<CR>', { desc =  "Previous buffer" })
vim.keymap.set('n', ']B', ':BufferLineMoveNext<CR>', { desc = "Move buffer to the right" })
vim.keymap.set('n', '[B', ':BufferLineMovePrev<CR>', { desc = "Move buffer to the left" })

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    ['<CR>'] = cmp.mapping.confirm({select = false}),
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})
