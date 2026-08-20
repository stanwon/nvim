return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个缓冲区" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "下一个缓冲区" },
        { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "跳转缓冲区 1" },
        { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "跳转缓冲区 2" },
        { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "跳转缓冲区 3" },
        { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "跳转缓冲区 4" },
        { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "跳转缓冲区 5" },
        { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "跳转缓冲区 6" },
        { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "跳转缓冲区 7" },
        { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "跳转缓冲区 8" },
        { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "跳转缓冲区 9" },
    },
    opts = {
        options = {
            -- VSCode 风格：图标 + 文件名 + 修改圆点 + LSP 诊断标记
            show_close_icon = false,
            show_buffer_close_icons = true,
            separator_style = "slant",
            indicator = { style = "icon", icon = "▎" },
            modified_icon = "●",
            diagnostics = "nvim_lsp",
        },
    },
}
