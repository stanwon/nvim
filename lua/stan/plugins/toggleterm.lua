return {
    'akinsho/toggleterm.nvim',
    version = "*",
    event = "VeryLazy",
    config = function()
        require("toggleterm").setup({
            -- 弹窗形式打开（宽高用函数计算，取屏幕 80%）
            direction = "float",
            float_opts = {
                border = "curved",
                width = function()
                    return math.floor(vim.o.columns * 0.8)
                end,
                height = function()
                    return math.floor(vim.o.lines * 0.8)
                end,
            },
            -- 隐藏而非退出：终端进程继续运行，重新打开秒回
            hidden = true,
            -- 终端内按 <C-\> 隐藏/显示（Esc 原样留给终端程序）
            open_mapping = "<C-\\>",
            terminal_mappings = true,
        })

        vim.api.nvim_create_autocmd("TermOpen", {
            callback = function()
                if vim.bo.filetype == "toggleterm" then
                    -- normal 模式（C-\C-n 退出终端模式后）按 Esc 隐藏
                    vim.keymap.set("n", "<Esc>", "<Cmd>ToggleTerm<CR>", { buffer = 0, desc = "隐藏终端" })
                end
            end,
        })
    end,
}
