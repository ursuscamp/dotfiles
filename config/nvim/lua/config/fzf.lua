local fzf = require("fzf-lua")
local fzf_actions = require("fzf-lua.actions")

fzf.setup({
  ui_select = true,
  winopts = {
    row = 1,
    col = 0,
    width = 1,
    height = 0.35,
    border = "top",
    preview = {
      layout = "horizontal",
      horizontal = "right:50%",
    },
  },
  keymap = {
    builtin = {
      ["<S-Down>"] = "preview-page-down",
      ["<S-Up>"] = "preview-page-up",
    },
  },
  actions = {
    files = {
      ["enter"] = fzf_actions.file_edit,
      ["ctrl-y"] = fzf_actions.file_edit,
    },
  },
  files = {
    cwd_prompt = false,
  },
  buffers = {
    actions = {
      ["enter"] = fzf_actions.file_edit,
      ["ctrl-y"] = fzf_actions.file_edit,
    },
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' --glob '!.jj' -e",
  },
  live_grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' --glob '!.jj' -e",
  },
  colorschemes = {
    live_preview = true,
    winopts = {
      height = 0.55,
      width = 0.35,
    },
  },
})

local colorscheme_picker = function()
  fzf.colorschemes({
    live_preview = true,
  })
end

return {
  colorscheme_picker = colorscheme_picker,
}
