-- --------------------------------------------------------------------
-- Keep Window & Cursor Position When Switching Buffers
-- https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
-- --------------------------------------------------------------------
local SAVED_BUF_VIEW = {}
---- Save current view settings on a per-window, per-buffer basis.
local function auto_save_win_view()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  if SAVED_BUF_VIEW[win] == nil then
    SAVED_BUF_VIEW[win] = {}
  end
  SAVED_BUF_VIEW[win][buf] = vim.fn.winsaveview()
end

---- Restore current view settings.
local function auto_restore_win_view()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  if SAVED_BUF_VIEW and SAVED_BUF_VIEW[win] and SAVED_BUF_VIEW[win][buf] then
    local v = vim.fn.winsaveview()
    local atStartOfFile = (v.lnum == 1 and v.col == 0)
    if atStartOfFile and not vim.wo.diff then
      vim.fn.winrestview(SAVED_BUF_VIEW[win][buf])
    end
    SAVED_BUF_VIEW[buf] = nil
  end
end

---- Set up autocommands to preserve window view when switching buffers.
vim.api.nvim_create_autocmd('BufLeave', {
  pattern = '*',
  callback = auto_save_win_view,
})
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = auto_restore_win_view,
})
