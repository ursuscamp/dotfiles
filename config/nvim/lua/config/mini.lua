local miniicons = require("mini.icons")
miniicons.setup()
miniicons.tweak_lsp_kind()

local mininotify = require("mini.notify")
mininotify.setup()
vim.notify = mininotify.make_notify()

local minifiles = require("mini.files")
minifiles.setup()

local minibufremove = require("mini.bufremove")
minibufremove.setup()

local minidiff = require("mini.diff")
minidiff.setup()

local minipairs = require("mini.pairs")
minipairs.setup()

local minicompletion = require("mini.completion")
minicompletion.setup({
  lsp_completion = {
    auto_setup = false,
    source_func = "omnifunc",
  },
  window = {
    info = {
      border = "rounded",
    },
    signature = {
      border = "rounded",
    },
  },
})

local minisnippets = require("mini.snippets")
local gen_loader = minisnippets.gen_loader
local lang_patterns = {
  -- Markdown code blocks use the injected `markdown_inline` language.
  markdown_inline = { "markdown.json" },
}
minisnippets.setup({
  snippets = {
    gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },
})

-- Expose loaded snippets to completion engines like mini.completion.
minisnippets.start_lsp_server({ match = false })

local minisurround = require("mini.surround")
minisurround.setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})

local ministatusline = require("mini.statusline")
ministatusline.setup({
  content = {
    active = function()
      local mode, mode_hl = ministatusline.section_mode({ trunc_width = 80 })
      local git = ministatusline.section_git({ trunc_width = 40 })
      local diff = ministatusline.section_diff({ trunc_width = 60 })
      local diagnostics = ministatusline.section_diagnostics({ trunc_width = 75 })
      local filename = ministatusline.section_filename({ trunc_width = 120 })
      local fileinfo = ministatusline.section_fileinfo({ trunc_width = 120 })
      local location = ministatusline.section_location({ trunc_width = 75 })
      local searchcount = ministatusline.section_searchcount({ trunc_width = 75 })

      return ministatusline.combine_groups({
        { hl = mode_hl,                 strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = mode_hl,                  strings = { searchcount, location } },
      })
    end,
    inactive = function()
      local filename = ministatusline.section_filename({ trunc_width = 120 })
      local fileinfo = ministatusline.section_fileinfo({ trunc_width = 120 })

      return ministatusline.combine_groups({
        { hl = "MiniStatuslineInactive", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineInactive", strings = { fileinfo } },
      })
    end,
  },
})

local miniindentscope = require("mini.indentscope")
miniindentscope.setup({
  symbol = "│",
  draw = {
    animation = miniindentscope.gen_animation.none(),
  },
})

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
    {
      { mode = "n",          keys = "<Leader>f", desc = "Files" },
      { mode = "n",          keys = "<Leader>b", desc = "Buffers" },
      { mode = "n",          keys = "<Leader>h", desc = "Healthcheck" },
      { mode = "n",          keys = "<Leader>g", desc = "Git" },
      { mode = { "n", "x" }, keys = "<Leader>m", desc = "Mermaid" },
      { mode = "n",          keys = "<Leader>s", desc = "Splits" },
    },
  },
  window = {
    delay = 250,
  },
})

return {
  files = minifiles,
  bufremove = minibufremove,
  pairs = minipairs,
  completion = minicompletion,
  snippets = minisnippets,
  surround = minisurround,
  statusline = ministatusline,
}
