vim.cmd [[colorscheme unokai]]

if (1 == 0) then
    if (vim.g.vscode == nil) then
        vim.api.nvim_create_autocmd('VimEnter', {
            pattern = "*",
            callback = function()
                if vim.fn.argc() == 0 then
                    vim.cmd [[yazi.exe]]
                end
            end
        })
    end
end
