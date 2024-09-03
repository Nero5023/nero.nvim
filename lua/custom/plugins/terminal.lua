return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        -- exist to normal mode in [t]erminal
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n>]], opts)
        -- Move window focus using Alt-{h,j,k,l}
        vim.keymap.set('t', '<A-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<A-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<A-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<A-l>', [[<Cmd>wincmd l<CR>]], opts)
        -- vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end

      -- Only set up these mappings in toggle term use term://*toggleterm#*
      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'

      require('toggleterm').setup {
        -- <C-t> to toggle the terminal
        open_mapping = [[<C-t>]],
      }
    end,
  },
}
