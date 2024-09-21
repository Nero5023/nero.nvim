return {
  'mrcjkb/rustaceanvim',
  version = '^4', -- Recommended
  lazy = false, -- This plugin is already lazy
  config = function()
    -- Set up rust analyzer path
    vim.g.rustaceanvim = {
      tools = {
        float_win_config = {
          -- https://github.com/mrcjkb/rustaceanvim/discussions/391
          -- rustaceanvim overrides the textDocument/hover, so need to set hover border here
          border = 'rounded',
        },
      },
      server = {
        cmd = function()
          local mason_registry = require 'mason-registry'
          local ra_binary = mason_registry.is_installed 'rust-analyzer'
              -- This may need to be tweaked, depending on the operating system.
              and mason_registry.get_package('rust-analyzer'):get_install_path() .. '/' .. mason_registry
                .get_package('rust-analyzer')
                :get_receipt()
                :get()['links']['bin']['rust-analyzer']
            or 'rust-analyzer'
          return { ra_binary } -- You can add args to the list, such as '--log-file'
        end,
      },
    }
  end,
}
