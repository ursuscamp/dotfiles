return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<c-y>"] = { "confirm", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
