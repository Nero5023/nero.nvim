local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set('n', '<leader>a', function()
  vim.cmd.RustLsp 'codeAction' -- supports rust-analyzer's grouping
  -- or vim.lsp.buf.codeAction() if you don't want grouping.
end, { silent = true, buffer = bufnr, desc = 'Code [A]ction' })

vim.keymap.set('n', '<leader>rm', function()
  vim.cmd.RustLsp 'expandMacro'
end, { silent = true, desc = '[R]ust expand[M]acro' })

vim.keymap.set('n', '<leader>re', function()
  vim.cmd.RustLsp 'explainError'
end, { silent = true, desc = '[R]ust [e]xplainError' })

vim.keymap.set('n', '<leader>rd', function()
  vim.cmd.RustLsp 'renderDiagnostic'
end, { silent = true, desc = '[R]ust render[D]iagnostic' })

vim.keymap.set('n', '<leader>rp', function()
  vim.cmd.RustLsp 'parentModule'
end, { silent = true, desc = '[R]ust [p]arentModule (Go to the parent module)' })

vim.keymap.set('n', '<leader>rr', function()
  vim.cmd.RustLsp 'run'
end, { silent = true, desc = '[R]ust [r]un' })

vim.lsp.inlay_hint.enable(true)
