return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- 按 <leader> 后 200ms 弹出提示菜单
        delay = 200,
        spec = {
            { "<leader>h", group = "Git (Gitsigns)" },
            { "<leader>x", group = "Diagnostics/Lists (Trouble)" },
            { "<leader>c", group = "Symbols/LSP jumps (Trouble)" },
            { "<leader>f", group = "Find (Telescope)" },
            { "<leader>t", group = "Toggles" },
        },
    },
    keys = {
        { "<leader>", "<cmd>WhichKey<cr>", desc = "which-key menu" },
    },
}
