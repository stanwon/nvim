local M = {
    "folke/zen-mode.nvim",
    main = "zen-mode",
    opts = {
        window = {
            backdrop = 0.95,
            width = .5,
            height = 1,
            options = {
                -- signcolumn = "no", -- disable signcolumn
                -- number = true, -- disable number column
                -- relativenumber = false, -- disable relative numbers
                -- cursorline = false, -- disable cursorline
                -- cursorcolumn = false, -- disable cursor column
                -- foldcolumn = "0", -- disable fold column
                -- list = false, -- disable whitespace characters
            },
        },
        plugins = {
            options = {
                enabled = true,
                ruler = false,
                showcmd = false,
                laststatus = 0,
            },
            twilight = { enabled = true },
            gitsigns = { enabled = false },
            tmux = { enabled = false },
            todo = { enabled = false },
        },
        on_open = function()
            vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
        end,
    },
    config = function(_, opts)
        vim.keymap.set('n', '<leader>z', function()require('zen-mode').toggle(opts)end, { noremap = true })
    end
}

return M
