vim.lsp.enable('clangd')
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--background-index",
        "--compile-commands-dir=build",
    },
})
