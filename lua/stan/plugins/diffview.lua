return {
    "sindrets/diffview.nvim",
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewFileHistory",
    },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git 变更面板" },
        { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "关闭 Git 变更面板" },
        { "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "Git 文件历史" },
    },
    opts = {
        keymaps = {
            disable_defaults = false, -- 保留默认键位，以下为自定义覆盖/新增
            view = {
                -- <Tab> 在 diff 窗口 → 焦点移到文件面板
                { "n", "<tab>", "<cmd>DiffviewFocusFiles<cr>", { desc = "焦点移到文件面板" } },
                -- <Esc> 关闭变更面板
                { "n", "<esc>", "<cmd>DiffviewClose<cr>", { desc = "关闭变更面板" } },
            },
            file_panel = {
                -- 文件面板内 <Tab> → 打开选中文件的 diff 并切回 diff 窗口
                { "n", "<tab>", function()
                    require("diffview.actions").select_entry()
                    vim.cmd("wincmd p") -- 焦点切回上一个窗口（diff 窗口）
                end, { desc = "打开选中文件的 diff" } },
                -- <Esc> 关闭变更面板
                { "n", "<esc>", "<cmd>DiffviewClose<cr>", { desc = "关闭变更面板" } },
            },
        },
    },
    config = function(_, opts)
        -- 注意：提供 config 后 lazy 不会自动 setup，必须手动调用
        require("diffview").setup(opts)
    end,
}
