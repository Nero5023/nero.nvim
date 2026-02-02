# Smart-Splits + Zellij Navigation Setup

Seamless navigation between Neovim splits and Zellij panes using `Alt+h/j/k/l`.

## Overview

This setup allows you to use `Alt+h/j/k/l` to:
- Move between Neovim splits when inside Neovim
- Move between Zellij panes when at the edge of Neovim or in a non-Neovim pane

## Components

1. **smart-splits.nvim** - Neovim plugin for split navigation
2. **vim-zellij-navigator** - Zellij plugin that detects Neovim and forwards keys
3. **Terminal configuration** - macOS requires Option key to be treated as Alt

## Terminal Configuration (macOS)

On macOS, the Option key produces special characters by default. You need to configure your terminal to treat Option as Alt.

### Ghostty

Add to `~/.config/ghostty/config`:

```
macos-option-as-alt = true
```

### Wezterm

Add to `~/.config/wezterm/wezterm.lua`:

```lua
local config = wezterm.config_builder()

-- Treat Option key as Alt for keybindings
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config
```

### Other Terminals

| Terminal | Setting |
|----------|---------|
| **Alacritty** | `option_as_alt: Both` in alacritty.toml |
| **iTerm2** | Preferences → Profiles → Keys → Left Option key → `Esc+` |
| **Kitty** | `macos_option_as_alt yes` in kitty.conf |

## Neovim Configuration

### smart-splits.nvim

`~/.config/nvim/lua/custom/plugins/smart_splits.lua`:

```lua
return {
    'mrjones2014/smart-splits.nvim',
    lazy = false, -- recommended for multiplexer integrations
    config = function()
        require('smart-splits').setup({
            multiplexer_integration = 'zellij',
        })

        -- Movement with Alt+h/j/k/l
        vim.keymap.set('n', '<A-h>', require('smart-splits').move_cursor_left)
        vim.keymap.set('n', '<A-j>', require('smart-splits').move_cursor_down)
        vim.keymap.set('n', '<A-k>', require('smart-splits').move_cursor_up)
        vim.keymap.set('n', '<A-l>', require('smart-splits').move_cursor_right)
    end,
}
```

## Zellij Configuration

`~/.config/zellij/config.kdl`:

The key configuration is adding `move_mod "alt"` to tell vim-zellij-navigator to send `Alt+h/j/k/l` to Neovim (instead of the default `Ctrl+h/j/k/l`).

```kdl
keybinds {
    shared_among "normal" "locked" {
        bind "Alt h" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "left";
                move_mod "alt";  // <-- This makes it send Alt+h to Neovim
            };
        }
        bind "Alt j" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "down";
                move_mod "alt";
            };
        }
        bind "Alt k" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "up";
                move_mod "alt";
            };
        }
        bind "Alt l" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "right";
                move_mod "alt";
            };
        }
    }
}
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  User presses Alt+h                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Terminal (Ghostty/Wezterm) sends escape sequence to Zellij    │
│  (requires macos-option-as-alt = true)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Zellij intercepts Alt+h, triggers vim-zellij-navigator        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  vim-zellij-navigator checks: Is current pane running Neovim?  │
└─────────────────────────────────────────────────────────────────┘
                    │                       │
                    ▼                       ▼
            ┌───────────────┐       ┌───────────────────────┐
            │  Yes (Neovim) │       │  No (shell/other)     │
            └───────────────┘       └───────────────────────┘
                    │                       │
                    ▼                       ▼
    ┌───────────────────────────┐   ┌───────────────────────┐
    │ Send Alt+h to Neovim      │   │ Zellij moves focus    │
    │ (because move_mod "alt")  │   │ to adjacent pane      │
    └───────────────────────────┘   └───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────┐
    │ smart-splits handles it:  │
    │ - Move to Neovim split    │
    │ - Or signal Zellij to     │
    │   move to adjacent pane   │
    └───────────────────────────┘
```

## Troubleshooting

### Alt key not working

1. **Test in Neovim**: In insert mode, press `Ctrl+v` then `Option+h`
   - Should show `^[h` (escape + h)
   - If you see `˙` or other special character, terminal config isn't applied

2. **Restart terminal completely** after changing config (not just new tab)

### Navigation works outside Zellij but not inside

1. Check vim-zellij-navigator detects Neovim:
   ```vim
   :!zellij action list-clients
   ```
   Should show `nvim` in RUNNING_COMMAND column

2. Verify smart-splits detects Zellij:
   ```vim
   :lua print(require('smart-splits.mux').get().type)
   ```
   Should print `zellij`

### vim-zellij-navigator sends wrong key

By default, vim-zellij-navigator sends `Ctrl+h/j/k/l`. Add `move_mod "alt"` to each binding to send `Alt+h/j/k/l` instead.

## Key Mappings Summary

| Key | Action |
|-----|--------|
| `Alt+h` | Move focus left |
| `Alt+j` | Move focus down |
| `Alt+k` | Move focus up |
| `Alt+l` | Move focus right |

These work seamlessly across:
- Neovim splits (within a single Neovim instance)
- Zellij panes (between different terminal panes)
- Mixed scenarios (from Neovim to shell pane and vice versa)
