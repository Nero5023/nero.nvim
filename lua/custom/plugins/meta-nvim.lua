local dir = vim.fn.has('mac') == 1 and '/Users/nero/.config/nvim-meta' or '/usr/share/fb-editor-support/nvim'

return {
  dir = dir,
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
      -- the old nvim-lspconfig setup API is deprecated https://www.reddit.com/r/neovim/comments/1nmh99k/beware_the_old_nvimlspconfig_setup_api_is/
      -- require('lspconfig')[lsp].setup {}
      vim.lsp.enable(lsp)
    end

    -- set up MERCURIAL
    require('meta.hg').setup()

    --#region set up command
    -- TODO: duplicate code bellow, wrap the run arc rusck check cmd
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

    -- Not very successful, the errorformat is not correct here
    vim.api.nvim_create_user_command('AsyncMakeBxl', function()
      local command = 'arc rust-check --target fbcode//buck2/app/buck2_bxl:buck2_bxl'

      local lines = { '' }

      local winnr = vim.fn.win_getid()
      local bufnr = vim.api.nvim_win_get_buf(winnr)

      local output = vim.fn.system 'hg root'
      if vim.v.shell_error ~= 0 then
        print('error running `hg root`: ' .. output)
        return
      end
      local hg_root = output
      local original_crwd = vim.fn.getcwd()

      local function on_event(job_id, data, event)
        if event == 'stdout' or event == 'stderr' then
          if data then
            vim.list_extend(lines, data)
          end
        end

        if event == 'exit' then
          vim.fn.setqflist({}, ' ', {
            title = command,
            lines = lines,
            efm = vim.api.nvim_get_option_value('errorformat', { buf = bufnr }),
          })
          vim.api.nvim_command 'doautocmd QuickFixCmdPost'
          vim.cmd('lcd ' .. original_crwd)
        end
      end

      -- go to the hg root to fix relative path issue in quickfix
      vim.cmd('lcd ' .. hg_root)

      -- vim.cmd 'make'

      -- reset dir
      -- vim.cmd('lcd ' .. original_crwd)

      local job_id = vim.fn.jobstart(command, {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = on_event,
        stdout_buffered = true,
        stderr_buffered = true,
      })
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

    -- set up quickfix make cmd for buck2
    vim.api.nvim_create_user_command('MakeCurrent', function()
      -- get the absolute path of the current buffer
      local file_path = vim.fn.expand '%:p'

      -- set makeprg with the file path
      vim.opt.makeprg = 'arc rust-check --path ' .. vim.fn.shellescape(file_path)

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

    -- setup metamate/code-compose
    require('meta.metamate').init {
      completionKeymap = '<C-e>',
      virtualTextHighlightGroup = 'TabLine',
    }
  end,
}
