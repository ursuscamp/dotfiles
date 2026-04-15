vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.plugins")
require("config.mini")
require("config.fzf")
require("config.sessions")
require("config.mermaid")
require("config.mason")
require("config.lsp")
require("config.keymaps")
require("config.autocmds")

require("mini.clue").ensure_all_triggers()
