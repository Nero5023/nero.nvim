return { -- Autocompletion
  --TODO: replace with blink.nvim https://github.com/Saghen/blink.cmp
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      -- snippets
      'L3MON4D3/LuaSnip', -- snippet engine
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        -- usefuly snippets resources
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
            -- friendly-snippets - enable standardized comments snippets
            require('luasnip').filetype_extend('lua', { 'luadoc' })
            require('luasnip').filetype_extend('python', { 'pydoc' })
            require('luasnip').filetype_extend('rust', { 'rustdoc' })
            require('luasnip').filetype_extend('sh', { 'shelldoc' })
          end,
        },
      },
    },
    'saadparwaiz1/cmp_luasnip', -- snippet completions

    -- cmp plugins
    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp-signature-help',

    -- LuaLS setup for source used in nvim-cmp
    {
      'folke/lazydev.nvim',
      ft = 'lua', -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  config = function()
    -- See `:help cmp`
    require 'custom.auto_complete'
  end,
}
