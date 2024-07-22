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

require('telescope').setup {
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
        ['<C-j>'] = require('telescope.actions').close,
      },
    },
  },
  -- pickers = {}
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

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
  builtin.live_grep(opts)
end
--#endregion

vim.keymap.set('n', '<C-`>', function()
  set_search_path(vim.fn.getcwd())
end, { desc = 'Reset telescope search path to project root (` -> ~ -> project root)' })

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[ ] [S]earch existing [B]bffers' })

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
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
