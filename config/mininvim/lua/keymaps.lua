vim.keymap.set('n', '<C-q>', ':qa!<CR>', { desc = "Quit all (w/o saving)" })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = "Quit window" })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Write buffer" })
vim.keymap.set('n', '<leader>c', ':bd<CR>', { desc = "Close buffer" })
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "File tree" })


-- Move windows more easily
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
