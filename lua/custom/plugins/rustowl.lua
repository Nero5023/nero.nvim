return {
  -- Visualize ownership and lifetimes in Rust for debugging and optimization
  'cordx56/rustowl',
  dependencies = { 'neovim/nvim-lspconfig' },
  keys = {
    { '<leader>ro', desc = 'Trigger RustOwl Cursor Action' },
  },
  config = function()
    require('lspconfig').rustowl.setup {
      trigger = {
        hover = false, -- disable the default behavior to triger rustowl when hover
      },
    }

    vim.api.nvim_set_keymap(
      'n',
      '<leader>ro',
      "<cmd>lua require('rustowl').rustowl_cursor()<CR>",
      { noremap = true, silent = true, desc = 'Trigger RustOwl Cursor Action' }
    )
  end,
}
