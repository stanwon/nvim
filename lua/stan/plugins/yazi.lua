local M = {
    "mikavilpas/yazi.nvim",
    version = "*",         -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
        -- 👇 in this section, choose your own keymappings!
        {
            "<leader>-",
            mode = { "n", "v" },
            "<cmd>Yazi<cr>",
            desc = "在当前文件处打开 Yazi",
        },
        {
            -- Open in the current working directory
            "<leader>cw",
            "<cmd>Yazi cwd<cr>",
            desc = "在 nvim 工作目录打开 Yazi",
        },
        {
            "<c-up>",
            "<cmd>Yazi toggle<cr>",
            desc = "恢复上次 Yazi 会话",
        },
    },
    opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = false,
        keymaps = {
            show_help = "<f1>",
        },
        -- 按 <Esc> 退出 yazi（发送 q 给 yazi 进程触发 close，替代默认的 q 键）
        set_keymappings_function = function(yazi_buffer, config, context)
            -- 先保留默认键位（yazi.lua 中默认 set_keymappings 在此之后调用，
            -- 但默认键位不包含 <Esc>，所以下面的覆盖不会被冲掉）
            require("yazi.config").set_keymappings(yazi_buffer, config, context)
            vim.keymap.set("t", "<esc>", "q", { buffer = yazi_buffer, desc = "退出 yazi" })
        end,
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
        -- mark netrw as loaded so it's not loaded at all.
        --
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        vim.g.loaded_netrwPlugin = 1
    end,
}

return M
