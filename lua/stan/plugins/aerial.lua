local M = {
    'stevearc/aerial.nvim',
    main = "aerial",
    event = "VeryLazy",
    opts = {
        backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
            -- 仅保留打开/关闭侧边栏的映射，且限定在当前 buffer
            vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { buffer = bufnr })
        end,
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
        },
    },
    -- Optional dependencies
    dependencies = {
        -- 重写版在 main 分支（master 已锁定，旧版与 nvim 0.12 的 iter_matches 格式不兼容，会崩）
        { "nvim-treesitter/nvim-treesitter", branch = "main" },
        "nvim-tree/nvim-web-devicons"
    },
}

return M
