local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.wrap = true
vim.o.autochdir = true
vim.o.list = true
vim.o.listchars = "tab:> ,trail:▫"

local telescope = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "LukasPietzschmann/telescope-tabs",
    "FeiyouG/command_center.nvim",
  },
  config = function()
    local m = { noremap = true, nowait = true }
    local builtin = require("telescope.builtin")
    local ts = require("telescope")
    ts.setup({
      defaults = {
        mappings = {
          i = {
            ["<c-k>"] = "move_selection_previous",
            ["<c-j>"] = "move_selection_next",
            ["<c-h>"] = "preview_scrolling_up",
            ["<c-l>"] = "preview_scrolling_down",
            ["<esc>"] = "close",
          },
        },
        color_devicons = true,
        prompt_prefix = "🔍 ",
        selection_caret = " ",
      },
    })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, m)
    vim.keymap.set("n", "<leader>fb", builtin.buffers, m)
    ts.load_extension("telescope-tabs")
    ts.load_extension("command_center")
  end,
}

local deus = {
  "theniceboy/nvim-deus",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd[[colorscheme deus]]
  end,
}

require("lazy").setup({
  deus,
  telescope,
})
