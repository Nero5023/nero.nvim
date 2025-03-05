local function is_terminal_window(win_id)
  local buf = vim.api.nvim_win_get_buf(win_id) -- get the buf in the win
  return vim.bo[buf].buftype == 'terminal'
end

local function get_first_terminal_window()
  local tabpage = vim.api.nvim_get_current_tabpage()
  -- list all windows
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)

  for _, win in ipairs(wins) do
    if is_terminal_window(win) then
      return win
    end
  end
  return nil
end

local function get_first_non_terminal_window()
  local tabpage = vim.api.nvim_get_current_tabpage()
  -- list all windows
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)

  for _, win in ipairs(wins) do
    if not is_terminal_window(win) then
      return win
    end
  end
  return nil
end

local WIN_BEFORE_SWITCH_TO_TERMINAL = nil

local function terminal_logic()
  local win_id = vim.api.nvim_get_current_win()

  if is_terminal_window(win_id) then
    -- Switch to last window
    --
    if WIN_BEFORE_SWITCH_TO_TERMINAL == nil then
      -- just go to the first non terminal window
      WIN_BEFORE_SWITCH_TO_TERMINAL = get_first_non_terminal_window()
    end
    vim.api.nvim_set_current_win(WIN_BEFORE_SWITCH_TO_TERMINAL)
    WIN_BEFORE_SWITCH_TO_TERMINAL = nil
  else
    -- go to terminal
    --
    WIN_BEFORE_SWITCH_TO_TERMINAL = win_id
    local termina_win_id = get_first_terminal_window()
    if termina_win_id == nil then
      -- require('toggleterm').toggle()
      -- in the plugin, it also handle the cases below
      -- local count = vim.v.count  -- 获取数字前缀
      -- vim.cmd(count .. "ToggleTerm")  -- 执行类似 "3ToggleTerm" 的命令
      vim.cmd 'ToggleTerm'
    else
      vim.api.nvim_set_current_win(termina_win_id)
    end
  end
end

-- if mapping then
--   utils.key_map("n", mapping, '<Cmd>execute v:count . "ToggleTerm"<CR>', {
--     desc = "Toggle Terminal",
--     silent = true,
--   })
--   if config.insert_mappings then
--     utils.key_map("i", mapping, "<Esc><Cmd>ToggleTerm<CR>", {
--       desc = "Toggle Terminal",
--       silent = true,
--     })
--   end
-- end

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        -- exist to normal mode in [t]erminal
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n>]], opts)

        -- Move window focus using Alt-{h,j,k,l}
        vim.keymap.set('t', '<A-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<A-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<A-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<A-l>', [[<Cmd>wincmd l<CR>]], opts)
        -- vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
        --
        vim.keymap.set('t', '<C-t>', terminal_logic, opts)
      end

      -- Only set up these mappings in toggle term use term://*toggleterm#*
      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
      require('toggleterm').setup()
      -- require('toggleterm').setup {
      --   -- <C-t> to toggle the terminal
      --   open_mapping = [[<C-t>]],
      -- }

      vim.keymap.set('n', '<C-t>', terminal_logic)
    end,
  },
}
