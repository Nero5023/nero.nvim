-- Place the cursor on the first (dir > 0) or last (dir < 0) change of the diff
-- buffer that's currently focused.
local function place_at_edge(dir)
  local win = vim.api.nvim_get_current_win()
  if not vim.wo[win].diff then
    return
  end

  if dir > 0 then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
    -- `]c` moves to the change *after* the cursor, so it would skip a change
    -- that starts on line 1 (common: a file added by the commit).
    if vim.fn.diff_hlID(1, 1) == 0 then
      pcall(vim.cmd, 'normal! ]c')
    end
    return
  end

  local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
  vim.api.nvim_win_set_cursor(win, { last, 0 })
  if vim.fn.diff_hlID(last, 1) == 0 then
    pcall(vim.cmd, 'normal! [c')
    return
  end
  -- The file ends inside a change: back up to that block's first line, which is
  -- where Vim's own `[c` would have left us.
  local line = last
  while line > 1 and vim.fn.diff_hlID(line - 1, 1) ~= 0 do
    line = line - 1
  end
  vim.api.nvim_win_set_cursor(win, { line, 0 })
end

---Vim's `]c` / `[c`, extended to roll over into the neighbouring file instead of
---dead-ending on the last hunk — so reviewing a commit is one repeated key.
---
---Roll-over is deliberately two-step: the press that lands on the last change
---stays put (Vim's motion is a no-op there), and only the *next* press switches
---file. That makes it impossible to fly past a hunk by holding the key down.
---Unlike `<tab>`, it stops at the ends of the file list rather than cycling — a
---review sweep that silently loops is worse than one that says it's done.
---@param dir integer  1 = forward, -1 = backward
local function change_jump(dir)
  local win = vim.api.nvim_get_current_win()
  local before = vim.api.nvim_win_get_cursor(win)[1]

  pcall(vim.cmd, 'normal! ' .. vim.v.count1 .. (dir > 0 and ']c' or '[c'))
  if vim.api.nvim_win_get_cursor(win)[1] ~= before then
    return
  end

  -- No change left in this direction: continue in the neighbouring file.
  local view = require('diffview.lib').get_current_view()
  if not (view and view.panel and view.panel.cur_file) then
    return
  end

  local files = view.panel:ordered_file_list()
  local idx
  for i, f in ipairs(files) do
    if f == view.panel.cur_file then
      idx = i
      break
    end
  end

  local target = idx and idx + dir
  if not target or target < 1 or target > #files then
    vim.notify('[diffview] ' .. (dir > 0 and 'Last' or 'First') .. ' change', vim.log.levels.INFO)
    return
  end

  -- The next file's buffers are produced asynchronously, so the cursor can only
  -- be placed once one of them is actually shown. Register before switching to
  -- avoid missing the event.
  vim.api.nvim_create_autocmd('User', {
    pattern = 'DiffviewDiffBufWinEnter',
    once = true,
    callback = function()
      vim.schedule(function()
        place_at_edge(dir)
      end)
    end,
  })

  -- Not `actions.select_next_entry`: that one honours `v:count1`, which here is
  -- the count typed for `]c`, and it wraps around at the ends.
  view:set_file(files[target], false, true)
end

return { -- Single tabpage interface for cycling through diffs, file history, and merge conflicts
  'sindrets/diffview.nvim',
  -- Use the local clone so we can hack on sl/hg (Sapling) support directly.
  -- lazy.nvim treats `dir` as a local plugin and skips fetching from git.
  dir = '/home/nero/local_dev/diffview.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- Load only when a Diffview command is invoked; keeps startup fast since
  -- diffing is an on-demand workflow rather than something needed at boot.
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [D]iff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it file [H]istory' },
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = '[G]it diff [Q]uit' },
  },
  opts = {
    keymaps = {
      -- `]s` / `[s`: jump to the next/prev commit in the Sapling stack by
      -- reopening Diffview for the neighbour (see lua/custom/plugins/sl-stack.lua).
      -- `]` goes toward the base (older), `[` toward the tip (newer). Bound in
      -- both the diff windows and the file panel; these add to diffview's
      -- defaults (they don't replace them).
      view = {
        { 'n', ']s', function() require('sl-stack').next_in_stack() end, { desc = 'Diff next commit in stack' } },
        { 'n', '[s', function() require('sl-stack').prev_in_stack() end, { desc = 'Diff prev commit in stack' } },
        -- `]c` / `[c` also have to be re-bound here because
        -- nvim-treesitter-textobjects claims them for its next/prev-class
        -- motions in every buffer with a parser (lua/custom/plugins/treesitter.lua),
        -- diff panes included.
        { 'n', ']c', function() change_jump(1) end, { desc = 'Next change (rolls into next file)' } },
        { 'n', '[c', function() change_jump(-1) end, { desc = 'Prev change (rolls into prev file)' } },
      },
      file_panel = {
        { 'n', ']s', function() require('sl-stack').next_in_stack() end, { desc = 'Diff next commit in stack' } },
        { 'n', '[s', function() require('sl-stack').prev_in_stack() end, { desc = 'Diff prev commit in stack' } },
      },
    },
  },
}
