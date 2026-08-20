return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
        -- 默认不渲染，按 <leader>m 手动开关
        enabled = false,
    },
    keys = {
        {
            "<leader>m",
            function()
                -- 仅在 markdown 文件中切换渲染，避免误按报错
                if vim.bo.filetype == 'markdown' then
                    require('render-markdown').toggle()
                end
            end,
            desc = "开关 Markdown 渲染",
        },
    },
}
