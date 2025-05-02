return {
  -- a simple neovim plugin that renders diagnostics using virtual lines on top of the real line/col of code
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  config = function()
    require('lsp_lines').setup()
    vim.diagnostic.config { virtual_lines = true }
    vim.keymap.set('', '<Leader>td', require('lsp_lines').toggle, { desc = '[T]oggle lsp_lines [d]iagnostic' })
  end,
  event = 'LspAttach',
}
