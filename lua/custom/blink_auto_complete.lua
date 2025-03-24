local cmp = require 'blink.cmp'

cmp.setup {
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = {
    -- Set the preset to 'none' to disable the presets default setting
    preset = 'none',

    -- Select the [n]ext item
    ['<C-n>'] = { 'select_next' },
    -- Select the p]revious item
    ['<C-p>'] = { 'select_prev' },

    -- disable a keymap from the preset
    ['<C-e>'] = {},

    -- Accept ([y]es) the completion.
    --  This will auto-import if your LSP supports it.
    --  This will expand snippets if the LSP sent a snippet.
    ['<C-y>'] = { 'select_and_accept' },

    -- abort
    ['<C-c>'] = { 'hide' },

    -- Scroll the documentation window [b]ack / [f]orward
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    -- signature
    -- TODO: check why C-k not work, also not show in keymaps
    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },

    -- Think of <c-l> as moving to the right of your snippet expansion.
    --  So if you have a snippet that's like:
    --  function $name($args)
    --    $body
    --  end
    --
    -- <c-l> will move you to the right of each of the expansion locations.
    -- <c-h> is similar, except moving you backwards.
    ['<C-l>'] = { 'snippet_forward', 'fallback' },
    ['<C-h>'] = { 'snippet_backward', 'fallback' },
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  -- Default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
  -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
  -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
  --
  -- See the fuzzy documentation for more information
  fuzzy = { implementation = 'prefer_rust_with_warning' },

  completion = {
    menu = {
      -- border
      -- border = 'single',
      --
      -- customize draw the completion column
      draw = {
        -- not use colorful-menu
        -- columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', gap = 1, 'kind' } },
        --
        columns = { { 'label', gap = 1 }, { 'kind_icon', gap = 1, 'kind' } },
        -- columns = { { 'kind_icon' }, { 'label', gap = 1 } },
        components = {
          label = {
            text = function(ctx)
              return require('colorful-menu').blink_components_text(ctx)
            end,
            highlight = function(ctx)
              return require('colorful-menu').blink_components_highlight(ctx)
            end,
          },
        },
        -- highlight 'label' using treesitter
        -- treesitter = { 'lsp' },
      },
    },
    documentation = {
      -- border
      -- window = { border = 'single' }
      auto_show = true,
      auto_show_delay_ms = 300,
    },
  },
  -- signature = {
  -- window = { border = 'single' }
  --   enabled = true,
  -- },
  --
  cmdline = {
    completion = {
      menu = {
        auto_show = true,
      },
    },
  },
}
