-- Automatically highlights other instances of the word under your cursor.
-- This works with LSP, Treesitter, and regexp matching to find the other
-- instances.
return {
  'RRethy/vim-illuminate',
  event = 'LspAttach',
  keys = {
    { ']]', desc = 'Next Reference' },
    { '[[', desc = 'Prev Reference' },
  },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = { 'lsp', 'treesitter' },
    },
  },
  config = function(_, opts)
    require('illuminate').configure(opts)

    local function map(key, dir, buffer)
      vim.keymap.set('n', key, function()
        require('illuminate')['goto_' .. dir .. '_reference'](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
    end

    map(']]', 'next')
    map('[[', 'prev')

    -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map(']]', 'next', buffer)
        map('[[', 'prev', buffer)
      end,
    })

    -- set up hightlight group
    -- if we want to set with underline and some background color, we can set like this `vim.api.nvim_set_hl(0, 'IlluminatedWordText', { underline = true, bg = '#3c3836' })`
    vim.api.nvim_set_hl(0, 'IlluminatedWordText', { bg = 'NvimDarkYellow' })
    vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { bg = 'NvimDarkYellow' })
    vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { bg = 'NvimDarkYellow' })

    -- toggle this plugin, since some cases in rust, it will hightlight the whole block of code
    vim.keymap.set('n', '<leader>ti', ':IlluminateToggleBuf<CR>', { noremap = true, silent = true, desc = '[T]oggle [i]lluminate in buffer' })
  end,
}
