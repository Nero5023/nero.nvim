return {
  dir = '/usr/share/fb-editor-support/nvim',
  name = 'meta.nvim',
  dependencies = {
    'jose-elias-alvarez/null-ls.nvim',
  },
  config = function()
    require('meta').setup()
    require 'meta.lsp'
    -- 'cppls@meta', pyls@meta
    --'rust-analyzer@meta'
    local servers = { 'pyre@meta', 'thriftlsp@meta', 'pyre-codenav@meta', 'pyls@meta', 'buck2@meta' }
    for _, lsp in ipairs(servers) do
      require('lspconfig')[lsp].setup {}
    end

    -- set up MERCURIAL
    require('meta.hg').setup()

    --#region set up command
    -- TODO: duplicate code bellow
    -- set up quickfix make cmd for bxl
    vim.api.nvim_create_user_command('MakeBxl', function()
      vim.opt.makeprg = 'arc rust-check --target fbcode//buck2/app/buck2_bxl:buck2_bxl'

      local output = vim.fn.system 'hg root'
      if vim.v.shell_error ~= 0 then
        print('error running `hg root`: ' .. output)
        return
      end
      local hg_root = output
      local original_crwd = vim.fn.getcwd()

      -- go to the hg root to fix relative path issue in quickfix
      vim.cmd('lcd ' .. hg_root)

      vim.cmd 'make'

      -- reset dir
      vim.cmd('lcd ' .. original_crwd)
    end, { nargs = 0 })

    -- set up quickfix make cmd for buck2
    vim.api.nvim_create_user_command('MakeBuck2', function()
      vim.opt.makeprg = 'arc rust-check fbcode//buck2:buck2'

      local output = vim.fn.system 'hg root'
      if vim.v.shell_error ~= 0 then
        print('error running `hg root`: ' .. output)
        return
      end
      local hg_root = output
      local original_crwd = vim.fn.getcwd()

      -- go to the hg root to fix relative path issue in quickfix
      vim.cmd('lcd ' .. hg_root)

      vim.cmd 'make'

      -- reset dir
      vim.cmd('lcd ' .. original_crwd)
    end, { nargs = 0 })
    --#endregion
  end,
}
