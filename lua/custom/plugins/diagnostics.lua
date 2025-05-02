return {
  -- a simple neovim plugin that renders diagnostics using virtual lines on top of the real line/col of code
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  config = function()
    require('lsp_lines').setup()
    vim.diagnostic.config { virtual_lines = true }

    local function toggle()
      local new_value = not vim.diagnostic.config().virtual_lines
      vim.diagnostic.config {
        virtual_lines = new_value,
        -- when we turn off virtual_lines(i.e. lsp_lines), we need to turn on virtual_text, vice versa
        virtual_text = not new_value,
      }
    end

    vim.keymap.set('', '<Leader>td', toggle, { desc = '[T]oggle lsp_lines [d]iagnostic' })
  end,
  event = 'LspAttach',
}
