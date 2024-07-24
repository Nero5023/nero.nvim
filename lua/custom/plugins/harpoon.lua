return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local set = vim.keymap.set

    set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = '[a]dd to harpoon list' })
    set('n', '<leader>hl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '[l]list all items in harpoon' })

    -- Toggle previous & next buffers stored within Harpoon list
    set('n', '<C-S-P>', function()
      harpoon:list():prev()
    end, { desc = 'Go previous item in harpoon' })
    set('n', '<C-S-N>', function()
      harpoon:list():next()
    end, { desc = 'Go next item in harpoon' })

    for i = 1, 5 do
      set('n', '<leader>h' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Go to ' .. i .. 'th item in harpoon' })
    end
  end,
}
