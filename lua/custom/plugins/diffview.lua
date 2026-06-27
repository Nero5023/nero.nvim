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
      },
      file_panel = {
        { 'n', ']s', function() require('sl-stack').next_in_stack() end, { desc = 'Diff next commit in stack' } },
        { 'n', '[s', function() require('sl-stack').prev_in_stack() end, { desc = 'Diff prev commit in stack' } },
      },
    },
  },
}
