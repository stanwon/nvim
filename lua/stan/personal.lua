vim.cmd [[colorscheme everforest]]

vim.api.nvim_create_autocmd('VimEnter', {
    pattern = "*",
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd [[Yazi]]
        end
    end
})
