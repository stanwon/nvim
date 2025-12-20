local has_words_before = function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        return false
    end
    local line = vim.api.nvim_get_current_line()
    return line:sub(col, col):match("%s") == nil
end

local M = {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default',

            -- If completion hasn't been triggered yet, insert the first suggestion; if it has, cycle to the next suggestion.
            ['<Tab>'] = {
                function(cmp)
                    if has_words_before() then
                        return cmp.insert_next()
                    end
                end,
                'fallback',
            },
            -- Navigate to the previous suggestion or cancel completion if currently on the first one.
            ['<S-Tab>'] = { 'insert_prev' },
        },

        appearance = {
            nerd_font_variant = 'mono'
        },

        completion = {
            menu = { enabled = true },
            list = { selection = { preselect = true }, cycle = { from_top = true } },
            documentation = { auto_show = false }
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
    },

    opts_extend = { "sources.default" },
}

return M
