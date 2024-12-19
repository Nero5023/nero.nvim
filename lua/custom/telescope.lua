-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of `help_tags` options and
-- a corresponding preview of the help.
--
-- NOTE: Two important keymaps to use while in Telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- Telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

local telescope = require 'telescope'
local lga_actions = require 'telescope-live-grep-args.actions'
local actions = require 'telescope.actions'
telescope.setup {
  -- You can put your default mappings / updates / etc. in here
  --  All the info you're looking for is in `:help telescope.setup()`
  --
  -- defaults = {
  --   mappings = {
  --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
  --   },
  -- },
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = actions.close,
        -- freeze the current list and start a fuzzy search in the frozen list (search on search)
        -- search on reuslts
        ['<C-enter>'] = actions.to_fuzzy_refine,
        ['<C-s>'] = actions.select_horizontal,
        ['<C-x>'] = false,
      },
      n = {
        ['<C-j>'] = actions.close,
        ['<C-s>'] = actions.select_horizontal,
        ['<C-x>'] = false,
        ['H'] = function()
          -- Move to the beginning of the line in normal mode
          -- simulate the user input here
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('^', true, false, true), 'n', true)
        end,
        ['L'] = function()
          -- Move to the end of the line in normal mode
          -- simulate the user input here
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('$', true, false, true), 'n', true)
        end,
      },
    },
  },
  -- pickers = {}
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
    -- NOTE: maybe it can replaced by fzf-lua https://github.com/ibhagwan/fzf-lua
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = { -- extend mappings
        i = {
          -- TODO: maybe write a self deinfed function to add qutoe, add -t, add --iglob, since
          -- right now it will also qutoe for like "search-str" -tlua
          --
          -- Don't know why which-key not show up in grep when hitting <C-g>
          -- g -> grep
          ['<C-g><C-q>'] = lga_actions.quote_prompt(), -- grep quote
          ['<C-g><C-t>'] = lga_actions.quote_prompt { postfix = ' -t' }, -- grep type
          ['<C-g><C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' }, -- grep iglob
        },
      },
    },
  },
}

telescope.load_extension 'live_grep_args'

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'

--#region set up search in path logic
---@return string|nil
local function get_search_path()
  local path = vim.g.search_path
  if path == nil then
    -- when not set, we just use the project root as the search path
    path = vim.fn.getcwd()
  end
  return path
end

---@param path string|nil
local function set_search_path(path)
  if path == nil then
    path = vim.fn.getcwd()
  end
  vim.g.search_path = path
  vim.print('set search path: ' .. vim.g.search_path)
end

---Get the path that oil interface represent if in oil
---@return nil|string
local function get_search_path_in_oil()
  local oil = require 'oil'
  local oil_current_dir = oil.get_current_dir()
  if oil_current_dir == nil then
    -- not in oil current dir
    -- in this case, we just return nil
    return nil
  else
    -- in oil interface
    local cursor_oil_entry = oil.get_cursor_entry()
    if cursor_oil_entry == nil then
      return oil_current_dir
    elseif cursor_oil_entry.type == 'file' then
      return oil_current_dir
    elseif cursor_oil_entry.type == 'directory' then
      return vim.fs.joinpath(oil_current_dir, cursor_oil_entry.name)
    end
  end
end

---Check if is in oil interface
---@return boolean
local function is_in_oil()
  local oil = require 'oil'
  return oil.get_current_dir() ~= nil
end

---Use in telescope search, if it is in oil, it will set the path in oil as the global search_path
---and use that path for searhing. Else jsut return the global search_path
---@return string|nil
local function setup_telescope_search_path()
  local path = nil
  if is_in_oil() then
    -- if in oil, we just set the search path base in oil interface
    path = get_search_path_in_oil()
    set_search_path(path)
  else
    -- use the glocal search_path
    path = get_search_path()
  end
  vim.print('Searching in path: ' .. path)
  return path
end

local function find_files()
  local path = setup_telescope_search_path()
  local opts = {
    cwd = path,
  }
  builtin.find_files(opts)
end

local function grep_string()
  local path = setup_telescope_search_path()
  local opts = {
    cwd = path,
  }
  builtin.grep_string(opts)
end

local function live_grep()
  local path = setup_telescope_search_path()
  local opts = {
    cwd = path,
  }
  -- builtin.live_grep(opts)
  -- use live_grep_args here for so that the prompt will be using rg: https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
  telescope.extensions.live_grep_args.live_grep_args(opts)
end

local function builtin_live_grep()
  local path = setup_telescope_search_path()
  local opts = {
    cwd = path,
  }
  builtin.live_grep(opts)
end
--#endregion

-- we cannot map <C-`>, because it is an ASCII NUL (zero), we cannot map anyting to it
vim.keymap.set('n', '<leader>`', function()
  set_search_path(vim.fn.getcwd())
end, { desc = 'Reset telescope search path to project root (` -> ~ -> project root)' })

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin_live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch existing [B]bffers' })
vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch items in [Q]uickfix list' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>vf', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'search neo[v]im [f]iles' })

vim.keymap.set('n', '<leader>vp', function()
  local data_path = vim.fn.stdpath 'data'
  builtin.find_files {
    ---@diagnostic disable-next-line: param-type-mismatch
    cwd = vim.fs.joinpath(data_path, 'lazy'),
  }
end, { desc = 'search neo[v]im [f]iles' })
