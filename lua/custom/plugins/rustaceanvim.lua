return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  lazy = false, -- This plugin is already lazy
  config = function()
    vim.g.rustaceanvim = {
      -- the related keymaps are set at after/ftplugin/rust.lua
      tools = {
        float_win_config = {
          -- https://github.com/mrcjkb/rustaceanvim/discussions/391
          -- rustaceanvim overrides the textDocument/hover, so need to set hover border here
          border = 'rounded',
        },
      },
      server = {
        -- Set up rust analyzer path
        cmd = function()
          local ra_binary = nil
          if vim.fn.executable 'rust-analyzer' == 1 then
            ra_binary = 'ra_binary'
          else
            local mason_registry = require 'mason-registry'
            ra_binary = mason_registry.is_installed 'rust-analyzer' and vim.env.MASON .. '/bin/' .. 'rust-analyzer'
          end

          return { ra_binary } -- You can add args to the list, such as '--log-file'
        end,
      },
    }
  end,
}
