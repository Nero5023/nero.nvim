-- autopairs
-- https://github.com/windwp/nvim-autopairs

local config = {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    -- hock on cmp to add close pair to it if possible
    require('nvim-autopairs').setup {
      -- set up fast wrap as default, press <M-e> to fast wrap
      fast_wrap = {},
    }
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}

local config_for_blink = {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  -- dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    -- hock on cmp to add close pair to it if possible
    require('nvim-autopairs').setup {
      -- set up fast wrap as default, press <M-e> to fast wrap
      fast_wrap = {},
    }
    -- If you want to automatically add `(` after selecting a function or method
    -- local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    -- local cmp = require 'cmp'
    -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}

if os.getenv 'NVIM_BLINK_CMP' == '1' then
  return config_for_blink
else
  return config
end
