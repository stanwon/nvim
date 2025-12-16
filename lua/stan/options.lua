vim.g.mapleader = " "

vim.o.splitbelow = true
vim.o.splitright = true
vim.o.showmode = false
vim.o.clipboard = "unnamedplus"
vim.o.ignorecase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.list = true
vim.o.wrap = true
vim.o.autoindent = true
vim.o.termguicolors = true
vim.o.listchars = "tab:> ,trail:▫"
--vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
vim.o.statusline = "%{%v:lua.require'nvim-navic'.get_location()%}"

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.opt.jumpoptions:append("stack")
