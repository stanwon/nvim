require('stan.load_lazy')
require('stan.options')
require('stan.keymaps')
require('stan.ls.clangd')
require('stan.ls.lua_ls')

require('stan.aerial').setup()
vim.cmd [[colorscheme unokai]]

vim.api.nvim_create_autocmd('VimEnter', {
    pattern = "*",
    callback = function()
        vim.cmd [[Yazi]]
    end
})
