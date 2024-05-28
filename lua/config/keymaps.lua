vim.cmd 'source lua/config/keymaps.vim'

local set = vim.keymap.set

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Move focus between windows
--  See `:help wincmd` for a list of all window commands
set('n', '<M-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<M-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<M-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<M-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Set highlight on search, but clear on pressing <C-h> in normal mode
vim.opt.hlsearch = true
set({ 'n', 'v' }, '<C-h>', '<cmd>nohlsearch<CR>')

-- set <ESC>
set({ 'n', 'i', 'v', 's', 'x', 'o', 'l', 't' }, '<C-j>', '<Esc>', { noremap = true, silent = true })
set('c', '<C-j>', '<C-c>', { noremap = true, silent = true })

-- Execute lua
-- TODO: put these to in after ft lua file
set('n', '<leader>xl', function()
  -- get current line
  local line = vim.fn.getline '.'
  -- execute current line for lua
  vim.cmd('lua ' .. line)
end, { desc = 'Execute the current line as Lua code' })

-- Don't know why this will highlight the string "key", so add nohlsearch he
-- set('n', '<leader>xf', '<cmd>source %<CR>', { desc = 'Execute the current file' })
set('n', '<leader>xf', '<cmd>write<CR><cmd>source %<CR><cmd>nohlsearch<CR>', { desc = 'Execute the current file' })

-- , is <  . is > on the keyboard. t -> tall, s -> short
-- can find better way to adjust the window size
-- These mappings control the size of splits (height/width)
-- set("n", "<M-,>", "<c-w>5<")
-- set("n", "<M-.>", "<c-w>5>")
-- set("n", "<M-t>", "<C-W>+")
-- set("n", "<M-s>", "<C-W>-")
