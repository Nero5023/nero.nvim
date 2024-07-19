return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup {
      columns = { 'icon' },
      keymaps = {
        ['<C-/>'] = 'actions.show_help',
        ['<C-h>'] = false,
        -- ['<M-h>'] = 'actions.select_split',
        ['<C-s>'] = false,
        ['<C-v>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
        ['<C-x>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
      },
      view_options = {
        show_hidden = true,
      },
    }

    -- Open parent directory in current window
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

    -- Open parent directory in floating window
    vim.keymap.set('n', '<space>-', require('oil').toggle_float)
  end,
}
