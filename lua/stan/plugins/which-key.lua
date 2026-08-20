return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- 按 <leader> 后 200ms 弹出提示菜单
        delay = 200,
        spec = {
            { "<leader>h", group = "Git 操作" },
            { "<leader>x", group = "诊断/列表" },
            { "<leader>c", group = "符号/LSP 跳转" },
            { "<leader>f", group = "查找" },
            { "<leader>t", group = "开关" },
        },
    },
    keys = {
        { "<leader>", "<cmd>WhichKey<cr>", desc = "键位菜单" },
    },
}
