require('stan.load_lazy')
require('stan.options')
require('stan.keymaps')
require('stan.lsp.clangd')
require('stan.lsp.lua_ls')
require('stan.personal')

-- plugins
require('stan.aerial').setup()
require('stan.gitsigns')
require('stan.telescope')
require('nvim-navic').setup({ lsp = { auto_attach = true, } })
