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
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = { query = '@function.outer', desc = 'Select around part of a function' },
          ['if'] = { query = '@function.inner', desc = 'Select inner part of a function' },
          ['ac'] = { query = '@class.outer', desc = 'Select ouput part of a lcass region' },
          -- You can optionally set descriptions to the mappings (used in the desc parameter of
          -- nvim_buf_set_keymap) which plugins like which-key display
          ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
          -- You can also use captures from other query groups like `locals.scm`
          ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
        },
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true or false
        include_surrounding_whitespace = true,
      },
      move = {
        enable = true,
        goto_next_start = {
          [']f'] = { query = '@function.outer', desc = 'Move to next [f]unction (start)' },
          [']c'] = { query = '@class.outer', desc = 'Move to next [c]lass (start)' },
          [']a'] = { query = '@parameter.inner', desc = 'Move to next [a]rgument (start)' },
        },
        goto_next_end = {
          [']F'] = { query = '@function.outer', desc = 'Move to next [F]unction (end)' },
          [']C'] = { query = '@class.outer', desc = 'Move to next [C]lass (end)' },
          [']A'] = { query = '@parameter.inner', desc = 'Move to next [A]rgument (end)' },
        },
        goto_previous_start = {
          ['[f'] = { query = '@function.outer', desc = 'Move to previous [f]unction (start)' },
          ['[c'] = { query = '@class.outer', desc = 'Move to previous [c]lass (start)' },
          ['[a'] = { query = '@parameter.inner', desc = 'Move to previous [a]rgument (start)' },
        },
        goto_previous_end = {
          ['[F'] = { query = '@function.outer', desc = 'Move to previous [F]unction (end)' },
          ['[C'] = { query = '@class.outer', desc = 'Move to previous [C]lass (end)' },
          ['[A'] = { query = '@parameter.inner', desc = 'Move to previous [A]rgument (end)' },
        },
      },
    },
  },
  -- ['ac'] = { query = '@class.outer', desc = 'Select ouput part of a lcass region' },
  lazy = false,
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
    {
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        require('treesitter-context').setup {
          enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
          max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
          min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
          line_numbers = true,
          multiline_threshold = 20, -- Maximum number of lines to show for a single context
          trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
          mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
          -- Separator between context and content. Should be a single character string, like '-'.
          -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
          separator = nil,
          zindex = 20, -- The Z-index of the context window
          on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        }
        -- set highlight (hl) for TreesitterContextBottom with underline
        vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = 'Grey' })
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
