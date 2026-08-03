-- Sapling stack picker + in-Diffview stack navigation.
--
-- :SlStack / <leader>gs  open a Telescope picker of the current Sapling stack
--   (`stack()` = the draft commits you're working on), tip first, current
--   commit marked `@`. <CR> opens that commit's diff in Diffview via
--   `:DiffviewOpen <hash>^::<hash>`; <C-]> checks it out (`sl goto`).
--
-- :SlCommit / <leader>gc  same diff, but for the commit you're already on — no
--   picker step. Distinct from <leader>gd (`:DiffviewOpen`), which diffs the
--   *working copy* against the current commit rather than the commit itself.
--
-- Inside a single-commit Diffview, `]s` / `[s` (wired from diffview.lua) jump to
-- the next/prev commit in the stack by reopening Diffview for the neighbour.
--
-- The module is exposed via `package.loaded["sl-stack"]` so diffview keymaps can
-- `require("sl-stack")` even though this file itself returns a lazy plugin spec.

local M = {}

-- ASCII Unit Separator (0x1f): a field delimiter that never appears in commit
-- hashes or subject lines, so parsing template output is unambiguous.
local SEP = "\31"

---Run `sl` with a list of args (no shell, so revsets like `stack()` need no quoting).
---@param args string[]
---@return integer code, string[] out
local function sl_lines(args)
  local cmd = { "sl" }
  vim.list_extend(cmd, args)
  local out = vim.fn.systemlist(cmd)
  return vim.v.shell_error, out
end

---The current stack's node hashes, tip first (same order as the picker).
---@return string[]? nodes, string? err
local function stack_nodes()
  local code, out = sl_lines { "log", "-r", "reverse(stack())", "-T", "{node}\n" }
  if code ~= 0 then
    return nil, "`sl log` failed: " .. table.concat(out, " ")
  end
  local nodes = {}
  for _, n in ipairs(out) do
    n = vim.trim(n)
    if n ~= "" then
      nodes[#nodes + 1] = n
    end
  end
  return nodes
end

---Collect the current stack's commits, tip first, for the picker.
---@return table[]? commits  list of { node, short, desc, is_current }
---@return string? err
local function get_stack()
  -- Working-copy parent, to mark the current commit with `@`.
  local code, cur = sl_lines { "log", "-r", ".", "-T", "{node}" }
  if code ~= 0 then
    return nil, "Not a Sapling repo (or `sl` failed): " .. table.concat(cur, " ")
  end
  local current = cur[1]

  local tmpl = "{node}" .. SEP .. "{node|short}" .. SEP .. "{desc|firstline}\n"
  local code2, lines = sl_lines { "log", "-r", "reverse(stack())", "-T", tmpl }
  if code2 ~= 0 then
    return nil, "`sl log` failed: " .. table.concat(lines, " ")
  end

  local commits = {}
  for _, line in ipairs(lines) do
    local node, short, desc = line:match("^(.-)" .. SEP .. "(.-)" .. SEP .. "(.*)$")
    if node and node ~= "" then
      commits[#commits + 1] = {
        node = node,
        short = short,
        desc = desc,
        is_current = node == current,
      }
    end
  end

  return commits
end

---Open Diffview for a single commit's changes.
---@param node string
local function diff_commit(node)
  vim.cmd("DiffviewOpen " .. node .. "^::" .. node)
end

---Diff the commit you're currently on, skipping the picker.
--- `.` is resolved to a hash rather than passed through as `.^::.` so the view's
--- `right.commit` is a real node — that's what `]s`/`[s` read to walk the stack.
function M.diff_current_commit()
  local code, out = sl_lines { "log", "-r", ".", "-T", "{node}" }
  local node = vim.trim(out[1] or "")
  if code ~= 0 or node == "" then
    vim.notify("[sl-stack] Cannot resolve `.`: " .. table.concat(out, " "), vim.log.levels.ERROR)
    return
  end
  diff_commit(node)
end

function M.open_picker()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("telescope.nvim is required for :SlStack", vim.log.levels.ERROR)
    return
  end
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local previewers = require "telescope.previewers"

  local commits, err = get_stack()
  if not commits then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  if #commits == 0 then
    vim.notify("No draft commits in the current stack.", vim.log.levels.INFO)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Sapling stack",
      -- Show tip-first order top-to-bottom (instead of Telescope's default
      -- bottom-anchored layout) so it reads like smartlog.
      sorting_strategy = "ascending",
      finder = finders.new_table {
        results = commits,
        entry_maker = function(c)
          local marker = c.is_current and "@" or " "
          return {
            value = c,
            display = string.format("%s %s  %s", marker, c.short, c.desc),
            ordinal = c.short .. " " .. c.desc,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = previewers.new_termopen_previewer {
        -- Lead with the commit message (title + Summary/Test Plan), then the
        -- diff. termopen runs in a pty, so `sl diff` auto-colorizes. `node` is a
        -- 40-hex hash, so interpolating it into `sh -c` is safe.
        get_command = function(entry)
          local node = entry.value.node
          return {
            "sh",
            "-c",
            "sl log -r " .. node .. " -T '{desc}\\n'; "
              .. "printf '\\n──────────────── diff ────────────────\\n\\n'; "
              .. "sl diff -c " .. node,
          }
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        -- <CR>: open the selected commit's diff in Diffview.
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            diff_commit(entry.value.node)
          end
        end)

        -- <C-]>: checkout (`sl goto`) the selected commit.
        map({ "i", "n" }, "<C-]>", function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            local code, out = sl_lines { "goto", entry.value.node }
            if code ~= 0 then
              vim.notify("sl goto failed: " .. table.concat(out, " "), vim.log.levels.ERROR)
            else
              vim.notify("Checked out " .. entry.value.short)
            end
          end
        end)

        return true
      end,
    })
    :find()
end

---The commit hash the current Diffview is showing (the `to` of `<hash>^::<hash>`),
---or nil if there's no Diffview or it isn't a single-commit diff.
---@return string?
local function current_view_commit()
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return nil
  end
  local view = lib.get_current_view()
  -- `view.right` is a Rev; only commit revs carry a `.commit` hash (LOCAL/STAGE
  -- revs — e.g. a plain `:DiffviewOpen` — do not), so this also filters those out.
  if view and view.right and type(view.right.commit) == "string" and view.right.commit ~= "" then
    return view.right.commit
  end
  return nil
end

---Jump to a neighbouring stack commit in Diffview.
---@param delta integer  +1 = toward base (down the tip-first list), -1 = toward tip
local function jump(delta)
  local commit = current_view_commit()
  if not commit then
    vim.notify("[sl-stack] Not viewing a single stack commit", vim.log.levels.WARN)
    return
  end

  local nodes, err = stack_nodes()
  if not nodes then
    vim.notify("[sl-stack] " .. err, vim.log.levels.ERROR)
    return
  end

  -- Locate the current commit (exact, then prefix — the view may hold a short hash).
  local idx
  for i, n in ipairs(nodes) do
    if n == commit then
      idx = i
      break
    end
  end
  if not idx then
    for i, n in ipairs(nodes) do
      if n:sub(1, #commit) == commit or commit:sub(1, #n) == n then
        idx = i
        break
      end
    end
  end
  if not idx then
    vim.notify("[sl-stack] Current commit is not in the stack", vim.log.levels.WARN)
    return
  end

  local target = idx + delta
  if target < 1 or target > #nodes then
    vim.notify("[sl-stack] " .. (delta < 0 and "Top" or "Bottom") .. " of stack", vim.log.levels.INFO)
    return
  end

  local node = nodes[target]
  vim.cmd "DiffviewClose"
  -- Defer the reopen: closing returns to the previous tabpage; opening on the
  -- next tick avoids re-entrancy while the close is still unwinding.
  vim.schedule(function()
    diff_commit(node)
  end)
end

function M.next_in_stack()
  jump(1)
end -- toward base (older)
function M.prev_in_stack()
  jump(-1)
end -- toward tip (newer)

-- Expose as require("sl-stack") even though the file returns a lazy spec below.
package.loaded["sl-stack"] = M

vim.api.nvim_create_user_command(
  "SlStack",
  M.open_picker,
  { desc = "Telescope picker of the current Sapling stack; <CR> opens the commit in Diffview" }
)

vim.api.nvim_create_user_command(
  "SlCommit",
  M.diff_current_commit,
  { desc = "Diffview of the current commit's own changes (`sl log -r .`)" }
)

vim.keymap.set("n", "<leader>gs", M.open_picker, { desc = "[G]it [S]tack (Sapling) -> Diffview" })
vim.keymap.set("n", "<leader>gc", M.diff_current_commit, { desc = "[G]it current [C]ommit changes -> Diffview" })

-- Register as a lazy.nvim "virtual" local plugin so the custom.plugins importer
-- picks this file up without fetching anything from the network.
return {
  dir = vim.fn.stdpath "config",
  name = "sl-stack.local",
  lazy = false,
}
