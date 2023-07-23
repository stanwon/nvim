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

local lualine = {
  "nvim-lualine/lualine.nvim",
  config = function()
	  require("lualine").setup{
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
  end
}

local comment = {
  "numToStr/Comment.nvim",
  config = function()
    local api = require("Comment.api")
    require("Comment").setup({
      padding = true,
      stickly = true,
      mappings = {
        basic = false,
        extra = false,
      },
    })
    vim.keymap.set("n", "<leader>/", function()
      api.toggle.linewise.current()
    end)
    vim.keymap.set("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>")
  end
}

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
  comment,
  lualine,
})
