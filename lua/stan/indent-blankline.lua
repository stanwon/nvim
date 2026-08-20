local M = {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    -- main = "ibl",
    -- opts = {},
    config = function()
        local type = 'rainbow'
        if (type == 'rainbow') then
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }

            local hooks = require "ibl.hooks"
            -- everforest 色板 (dark, medium)
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#e67e80" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#dbbc7f" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#7fbbb3" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#e69875" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#a7c080" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#d699b6" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#83c092" })
            end)

            require("ibl").setup { indent = { highlight = highlight } }
        else
            local highlight = {
                "CursorColumn",
                "Whitespace",
            }
            require("ibl").setup {
                indent = { highlight = highlight, char = "" },
                whitespace = {
                    highlight = highlight,
                    remove_blankline_trail = false,
                },
                scope = { enabled = false },
            }
        end
    end
}

return M
