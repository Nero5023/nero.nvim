return {
  {
    'folke/zen-mode.nvim', -- Plugin for focusing on current, remove unnecessary uis
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    cmd = { -- Only when user give command `ZenMode`, the plugin will be loaded
      'ZenMode',
    },
  },
  {
    'folke/twilight.nvim', -- Plugin for diming inactive parts of the code
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    cmd = { -- Only when user give command `ZenMode` or `Twilight`, the plugin will be loaded
      'Twilight',
    },
  },
  {
    'preservim/vim-pencil', -- Plugin for writing
    opts = {},
    init = function() end,
    dependencies = {
      'folke/zen-mode.nvim',
      'folke/twilight.nvim',
    },
    config = function()
      -- Define the funtion for trigger my deinfed write mode
      vim.api.nvim_create_user_command('WriteMode', function()
        vim.cmd 'ZenMode'
        vim.cmd 'TogglePencil'
        -- TODO: here is a bug here, the spell check will do like this
        -- 1. Writemode (Enter Write Mode )-> spell checking (Correct)
        -- 2. Writemode (Exit Write Mode) -> spell checking (Not Correct)
        -- 3. Writemode (Enter Write Mode) -> no spell checking (Not Correct)
        vim.opt.spell = not (vim.opt.spell:get()) ---@diagnostic disable-line
      end, { desc = 'Activate Write Mode for writing. Set up ZenMode and TogglePencil' })
    end,
    cmd = { -- Lazy load the plugin by using these command
      'Pencil',
      'TogglePencil',
      'WriteMode',
    },
  },
}
