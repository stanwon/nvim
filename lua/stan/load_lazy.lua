local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup({
    spec = {
        require("stan.yazi"),
        require("stan.trouble"),
        require("stan.aerial"),
        "neovim/nvim-lspconfig",
        "SmiteshP/nvim-navic",
        "lewis6991/gitsigns.nvim",
        { 'akinsho/toggleterm.nvim', version = "*", config = true },
        {
            'nvim-telescope/telescope.nvim',
            tag = 'v0.2.0',
            dependencies = { 'nvim-lua/plenary.nvim' }
        },
    },

    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
