return {
  -- a simple neovim plugin that renders diagnostics using virtual lines on top of the real line/col of code
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  config = function()
    require('lsp_lines').setup()
  end,
  event = 'LspAttach',
}
