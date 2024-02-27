vim.keymap.set('n', '<C-q>', ':qa!<CR>', { desc = "Quit all (w/o saving)" })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = "Quit window" })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Write buffer" })
vim.keymap.set('n', '<leader>c', ':bd<CR>', { desc = "Close buffer" })


-- Window stuff
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = "Split vertically" })
vim.keymap.set('n', '<leader>sh', '<cmd>split<CR>', { desc = "Split vertically" })


vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { desc = "Goto declaration" })
vim.keymap.set('n', 'gD', vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = "Goto implementation" })
