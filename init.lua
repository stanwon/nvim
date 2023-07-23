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
vim.o.clipboard = "unnamedplus"
vim.o.scrolloff = 7

local nvimtree = {
  "nvim-tree/nvim-tree.lua",
  config = function ()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
  end
}

local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function ()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "lua", "go" },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = false },
    })
  end,
}

local autopairs = {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  opts = {} -- this is equalent to setup({}) function
}

local surround = {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
    })
  end
}

local codeAction = {
  "weilbith/nvim-code-action-menu",
  cmd = "CodeActionMenu",
}

local lsp = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
  },
  config = function()
    -- cmp
    local cmp = require("cmp")
    cmp.setup({
      enabled = true,
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end
      },
      window = {
        completion = {
          border = {
            { "╭", "CmpBorder" },
            { "─", "CmpBorder" },
            { "╮", "CmpBorder" },
            { "│", "CmpBorder" },
            { "╯", "CmpBorder" },
            { "─", "CmpBorder" },
            { "╰", "CmpBorder" },
            { "│", "CmpBorder" },
          },
        },
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "vsnip" },
      }, {
        { name = "buffer" },
      }),
      mapping = {
        ['<C-e>'] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          end
        end, { "i", "s" }),
      }
    })

    -- lspconfig
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")
    local servers = { "lua_ls", "gopls" }
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })
    end
  end
}

local mason = {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  lazy = false,
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "gopls" },
      automatic_installation = true,
    })
  end,
}

local lualine = {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
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

-- save cursor position
vim.api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = "*",
  callback = function()
    vim.cmd[[
    if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    ]]
  end
})

-- splite help vertically
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "help",
  callback = function()
    vim.cmd[[
    wincmd L
    vertical resize +15
    ]]
  end
})

vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "markdown",
  callback = function()
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    local m = { noremap = true, nowait = true }
    vim.keymap.set("i", ";n", "<esc>/<++<cr>:noh<cr>cf>", m)
    vim.keymap.set("i", ";1", "# ", m)
    vim.keymap.set("i", ";2", "## ", m)
    vim.keymap.set("i", ";3", "### ", m)
    vim.keymap.set("i", ";4", "#### ", m)
    vim.keymap.set("i", ";5", "##### ", m)
    vim.keymap.set("i", ";6", "###### ", m)
    vim.keymap.set("i", ";b", "****<++++><esc>F*hi", m)
    vim.keymap.set("i", ";I", "**<++++><esc>F*i", m)
    vim.keymap.set("i", ";c", "``````<++++><esc>F`2hi", m)
    vim.keymap.set("i", ";C", "``<++++><esc>F`i", m)
    vim.keymap.set("i", ";i", "![](<++image-path++>)<esc>F]i", m)
    vim.keymap.set("i", ";u", "[](<++url++>)<esc>F]i", m)
    vim.keymap.set("i", ";t", "- [ ] ", m)
  end
})

require("lazy").setup({
  deus,
  telescope,
  comment,
  lualine,
  mason,
  lsp,
  codeAction,
  surround,
  autopairs,
  treesitter,
  nvimtree,
})
