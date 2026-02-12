local function realpath(path)
  local resolved = vim.fn.resolve(vim.fn.fnamemodify(path, ':p'))
  -- strip trailing slash for consistent concatenation
  return resolved:gsub('/$', '')
end

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
          -- we don't use the mason binary here
          local ra_binary = 'rust-analyzer'
          local cwd = realpath(vim.fn.getcwd())
          local fbsource_prefix = realpath(vim.fn.expand '~/fbsource')
          if cwd:match('^' .. fbsource_prefix) then
            ra_binary = fbsource_prefix .. '/xplat/tools/rust-analyzer/rust-analyzer'
          end

          return { ra_binary } -- You can add args to the list, such as '--log-file'
        end,
      },
    }
  end,
}
