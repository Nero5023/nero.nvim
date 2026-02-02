return {
    'mrjones2014/smart-splits.nvim',
    lazy = false, -- recommended for multiplexer integrations
    config = function()
        require('smart-splits').setup({
            -- Zellij integration is auto-detected
            multiplexer_integration = 'zellij',
        })

        -- Movement with Alt+h/j/k/l (vim-zellij-navigator now sends Alt keys)
        vim.keymap.set('n', '<A-h>', require('smart-splits').move_cursor_left)
        vim.keymap.set('n', '<A-j>', require('smart-splits').move_cursor_down)
        vim.keymap.set('n', '<A-k>', require('smart-splits').move_cursor_up)
        vim.keymap.set('n', '<A-l>', require('smart-splits').move_cursor_right)
    end,
}
