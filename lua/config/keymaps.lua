vim.cmd 'source ~/.config/nvim-nero/lua/config/keymaps.vim'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Move focus between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<M-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<M-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<M-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<M-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Set highlight on search, but clear on pressing <C-h> in normal mode
vim.opt.hlsearch = true
vim.keymap.set({ 'n', 'v' }, '<C-h>', '<cmd>nohlsearch<CR>')

-- set <ESC>
vim.keymap.set({ 'n', 'i', 'v', 's', 'x', 'o', 'l', 't' }, '<C-j>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('c', '<C-j>', '<C-c>', { noremap = true, silent = true })

-- Execute lua
-- TODO: put these to in after ft lua file
vim.keymap.set('n', '<leader>x', function()
  -- get current line
  local line = vim.fn.getline '.'
  -- execute current line for lua
  vim.cmd('lua ' .. line)
end, { desc = 'Execute the current line as Lua code' })

vim.keymap.set('n', '<leader><leader>x', '<cmd>source %<CR>', { desc = 'Execute the current file' })
