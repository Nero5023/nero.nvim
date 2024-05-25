return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  keys = {
    { '<c-s>', desc = 'Increment selection' },
    { '<bs>', desc = 'Decrement selection', mode = 'x' },
  },
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'python', 'rust' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-s>',
        node_incremental = '<C-s>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
  },
  config = function(_, opts)
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      config = function()
        -- When in diff mode, we want to use the default
        -- vim text objects c & C instead of the treesitter ones.
        local move = require 'nvim-treesitter.textobjects.move' ---@type table<string,fun(...)>
        local configs = require 'nvim-treesitter.configs'
        for name, fn in pairs(move) do
          if name:find 'goto' == 1 then
            move[name] = function(q, ...)
              if vim.wo.diff then
                local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
                for key, query in pairs(config or {}) do
                  if q == query and key:find '[%]%[][cC]' then
                    vim.cmd('normal! ' .. key)
                    return
                  end
                end
              end
              return fn(q, ...)
            end
          end
        end
      end,
    },
  },
}

-- CONFIGS FOR nvim-treesitter-textobjects

-- select
-- require('nvim-treesitter.configs').setup {
--   textobjects = {
--     select = {
--       enable = true,
--
--       -- Automatically jump forward to textobj, similar to targets.vim
--       lookahead = true,
--
--       keymaps = {
--         -- You can use the capture groups defined in textobjects.scm
--         ['af'] = '@function.outer',
--         ['if'] = '@function.inner',
--         ['ac'] = '@class.outer',
--         -- You can optionally set descriptions to the mappings (used in the desc parameter of
--         -- nvim_buf_set_keymap) which plugins like which-key display
--         ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
--         -- You can also use captures from other query groups like `locals.scm`
--         ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
--       },
--       -- You can choose the select mode (default is charwise 'v')
--       --
--       -- Can also be a function which gets passed a table with the keys
--       -- * query_string: eg '@function.inner'
--       -- * method: eg 'v' or 'o'
--       -- and should return the mode ('v', 'V', or '<c-v>') or a table
--       -- mapping query_strings to modes.
--       selection_modes = {
--         ['@parameter.outer'] = 'v', -- charwise
--         ['@function.outer'] = 'V', -- linewise
--         ['@class.outer'] = '<c-v>', -- blockwise
--       },
--       -- If you set this to `true` (default is `false`) then any textobject is
--       -- extended to include preceding or succeeding whitespace. Succeeding
--       -- whitespace has priority in order to act similarly to eg the built-in
--       -- `ap`.
--       --
--       -- Can also be a function which gets passed a table with the keys
--       -- * query_string: eg '@function.inner'
--       -- * selection_mode: eg 'v'
--       -- and should return true or false
--       include_surrounding_whitespace = true,
--     },
--   },
-- }
--
-- -- swap
-- require('nvim-treesitter.configs').setup {
--   textobjects = {
--     swap = {
--       enable = true,
--       swap_next = {
--         ['<leader>a'] = '@parameter.inner',
--       },
--       swap_previous = {
--         ['<leader>A'] = '@parameter.inner',
--       },
--     },
--   },
-- }
--
-- -- move
-- require('nvim-treesitter.configs').setup {
--   textobjects = {
--     move = {
--       enable = true,
--       set_jumps = true, -- whether to set jumps in the jumplist
--       goto_next_start = {
--         [']m'] = '@function.outer',
--         [']]'] = { query = '@class.outer', desc = 'Next class start' },
--         --
--         -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
--         [']o'] = '@loop.*',
--         -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
--         --
--         -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
--         -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
--         [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
--         [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
--       },
--       goto_next_end = {
--         [']M'] = '@function.outer',
--         [']['] = '@class.outer',
--       },
--       goto_previous_start = {
--         ['[m'] = '@function.outer',
--         ['[['] = '@class.outer',
--       },
--       goto_previous_end = {
--         ['[M'] = '@function.outer',
--         ['[]'] = '@class.outer',
--       },
--       -- Below will go to either the start or the end, whichever is closer.
--       -- Use if you want more granular movements
--       -- Make it even more gradual by adding multiple queries and regex.
--       goto_next = {
--         [']d'] = '@conditional.outer',
--       },
--       goto_previous = {
--         ['[d'] = '@conditional.outer',
--       },
--     },
--   },
-- }
