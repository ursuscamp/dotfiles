-- since this is just an example spec, don't actually load anything here and return an empty spec
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-y>"] = require("telescope.actions").select_default,
          },
        },
      },
    },
  },
  { "mrjones2014/smart-splits.nvim" },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
