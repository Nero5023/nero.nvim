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
      dap = {
        -- on attach, rustaceanvim fetches runnables and assumes each has cargoArgs;
        -- Meta's buck-based rust-analyzer returns runnables without them, which
        -- errors (debuggables.lua: index field 'cargoArgs') on every new buffer
        autoload_configurations = false,
      },
      server = {
        -- Set up rust analyzer path
        cmd = function()
          -- we don't use the mason binary here
          local ra_binary = 'rust-analyzer'
          local fbsource_prefix = realpath(vim.fn.expand '~/fbsource') .. '/'
          local function in_fbsource(path)
            return path ~= '' and vim.startswith(realpath(path) .. '/', fbsource_prefix)
          end
          -- check the file being opened as well as cwd, so fbsource files opened
          -- from outside ~/fbsource (e.g. `nvim ~/fbsource/...` from ~) still get Meta's binary
          if in_fbsource(vim.api.nvim_buf_get_name(0)) or in_fbsource(vim.fn.getcwd()) then
            ra_binary = fbsource_prefix .. 'xplat/tools/rust-analyzer/rust-analyzer'
          end

          return { ra_binary } -- You can add args to the list, such as '--log-file'
        end,
      },
    }
  end,
}
