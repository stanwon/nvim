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

local m = { noremap = true }

local dap = {
  "mfussenegger/nvim-dap",
  dependencies = {
    --[[ {
      "ravenxrz/DAPInstall.nvim",
      config = function()
        local dap_install = require("dap-install")
        dap_install.setup({
          installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
        })
      end
    }, ]]
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim",
    -- "ldelossa/nvim-dap-projects",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    --[[ dap.adapters.delve = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}' },
      }
    }
    dap.configurations.go = {
      {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}"
      },
      {
        type = "delve",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "${file}"
      },
      -- works with go.mod packages and sub packages
      {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
      }
    } ]]
    --[[ dap.adapters.lldb = {
      type = "executable",
      command = "/usr/bin/lldb-vscode",
      name = "lldb",
    }
    dap.configurations.cpp = {
      name = "Lanch",
      type = "lldb",
      request = "Lanch",
    } ]]
    vim.keymap.set("n", "<leader>'q", ":Telescope dap<CR>", m)
    vim.keymap.set("n", "<leader>'t", dap.toggle_breakpoint, m)
    vim.keymap.set("n", "<leader>'n", dap.continue, m)
    vim.keymap.set("n", "<leader>'s", dap.terminate, m)
    vim.keymap.set("n", "<leader>'u", dapui.toggle, m)

    vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

    vim.fn.sign_define('DapBreakpoint',
      { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition',
      { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointRejected',
      { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapLogPoint', {
      text = '',
      texthl = 'DapLogPoint',
      linehl = 'DapLogPoint',
      numhl = 'DapLogPoint'
    })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

    -- require("nvim-dap-projects").search_project_config()
    require("mason-nvim-dap").setup({
      ensure_installed = { "delve" },
      automatic_installation = false,
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
      }
    })
  end
}

local wilder = {
  'gelguy/wilder.nvim',
  config = function()
    local wilder = require('wilder')
    wilder.setup {
      modes = { ':' },
      next_key = '<Tab>',
      previous_key = '<S-Tab>',
      --[[ next_key = '<c-j>',
      previous_key = '<c-k>', ]]
    }
    wilder.set_option('use_python_remote_plugin', 0)
    wilder.set_option('renderer', wilder.popupmenu_renderer(
      wilder.popupmenu_palette_theme({
        highlights = {
          border = 'Normal', -- highlight to use for the border
        },
        left = { ' ', wilder.popupmenu_devicons() },
        right = { ' ', wilder.popupmenu_scrollbar() },
        border = 'rounded',
        max_height = '75%',      -- max height of the palette
        min_height = 0,          -- set to the same as 'max_height' for a fixed height window
        prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
        reverse = 0,             -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
      })
    ))
    wilder.set_option('pipeline', {
      wilder.branch(
        wilder.cmdline_pipeline({
          language = 'vim',
          fuzzy = 1,
        }), wilder.search_pipeline()
      ),
    })
  end
}

local fzf = {
  "ibhagwan/fzf-lua",
  keys = { "<c-f>" },
  config = function()
    local fzf = require('fzf-lua')
    vim.keymap.set('n', '<c-f>', function()
      -- fzf.live_grep_resume({ multiprocess = true, debug = true })
      fzf.grep({ search = "", fzf_opts = { ['--layout'] = 'default' } })
    end, m)
    vim.keymap.set('x', '<c-f>', function()
      -- fzf.live_grep_resume({ multiprocess = true, debug = true })
      fzf.grep_visual({ fzf_opts = { ['--layout'] = 'default' } })
    end, m)
    fzf.setup({
      global_resume = true,
      global_resume_query = true,
      winopts = {
        height     = 1,
        width      = 1,
        preview    = {
          layout = 'vertical',
          scrollbar = 'float',
        },
        fullscreen = true,
        vertical   = 'down:45%',  -- up|down:size
        horizontal = 'right:60%', -- right|left:size
        hidden     = 'nohidden',
      },
      keymap = {
        builtin = {
          ["<c-f>"]    = "toggle-fullscreen",
          ["<c-r>"]    = "toggle-preview-wrap",
          ["<c-p>"]    = "toggle-preview",
          ["<c-y>"]    = "preview-page-down",
          ["<c-l>"]    = "preview-page-up",
          ["<S-left>"] = "preview-page-reset",
        },
        fzf = {
          ["esc"]        = "abort",
          ["ctrl-h"]     = "unix-line-discard",
          ["ctrl-k"]     = "half-page-down",
          ["ctrl-b"]     = "half-page-up",
          ["ctrl-n"]     = "beginning-of-line",
          ["ctrl-a"]     = "end-of-line",
          ["alt-a"]      = "toggle-all",
          ["f3"]         = "toggle-preview-wrap",
          ["f4"]         = "toggle-preview",
          ["shift-down"] = "preview-page-down",
          ["shift-up"]   = "preview-page-up",
          ["ctrl-e"]     = "down",
          ["ctrl-u"]     = "up",
        },
      },
      previewers = {
        head = {
          cmd  = "head",
          args = nil,
        },
        git_diff = {
          cmd_deleted   = "git diff --color HEAD --",
          cmd_modified  = "git diff --color HEAD",
          cmd_untracked = "git diff --color --no-index /dev/null",
          -- pager        = "delta",      -- if you have `delta` installed
        },
        man = {
          cmd = "man -c %s | col -bx",
        },
        builtin = {
          syntax         = true,        -- preview syntax highlight?
          syntax_limit_l = 0,           -- syntax limit (lines), 0=nolimit
          syntax_limit_b = 1024 * 1024, -- syntax limit (bytes), 0=nolimit
        },
      },
      files = {
        -- previewer      = "bat",          -- uncomment to override previewer
        -- (name from 'previewers' table)
        -- set to 'false' to disable
        prompt       = 'Files❯ ',
        multiprocess = true, -- run command in a separate process
        git_icons    = true, -- show git icons?
        file_icons   = true, -- show file icons?
        color_icons  = true, -- colorize file|git icons
        -- executed command priority is 'cmd' (if exists)
        -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
        -- default options are controlled by 'fd|rg|find|_opts'
        -- NOTE: 'find -printf' requires GNU find
        -- cmd            = "find . -type f -printf '%P\n'",
        find_opts    = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        rg_opts      = "--color=never --files --hidden --follow -g '!.git'",
        fd_opts      = "--color=never --type f --hidden --follow --exclude .git",
      },
      buffers = {
        prompt        = 'Buffers❯ ',
        file_icons    = true, -- show file icons?
        color_icons   = true, -- colorize file|git icons
        sort_lastused = true, -- sort buffers() by last used
      },
    })
  end

}

local nvterm = {
  "NvChad/nvterm",
  config = function()
    vim.keymap.set("n", "<leader>h", function()
      require("nvterm.terminal").toggle "horizontal"
    end, m)
    vim.keymap.set("n", "<leader>v", function()
      require("nvterm.terminal").toggle "vertical"
    end, m)
    require("nvterm").setup({
      terminals = {
        shell = vim.o.shell,
        list = {},
        type_opts = {
          float = {
            relative = 'editor',
            row = 0.3,
            col = 0.25,
            width = 0.5,
            height = 0.4,
            border = "single",
          },
          horizontal = { location = "rightbelow", split_ratio = .3, },
          vertical = { location = "rightbelow", split_ratio = .5 },
        }
      },
      behavior = {
        autoclose_on_quit = {
          enabled = false,
          confirm = true,
        },
        close_on_exit = true,
        auto_insert = true,
      },
    })
  end,
}

local bufferline = {
  "akinsho/bufferline.nvim",
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      diagnostics = "nvim_lsp",
      -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      indicator = {
        icon = '▎', -- this should be omitted if indicator style is not 'icon'
        -- style = 'icon' | 'underline' | 'none',
        style = "icon",
      },
      show_buffer_close_icons = false,
      show_close_icon = false,
      enforce_regular_tabs = true,
      show_duplicate_prefix = false,
      tab_size = 16,
      padding = 0,
      separator_style = "thick",
    }
  }
}

local nvimtree = {
  "nvim-tree/nvim-tree.lua",
  config = function()
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
  "nvim-treesitter/playground",
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "query", "lua", "go" },
      highlight = {
        enable = true,
        use_languagetree = true,
      },
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
        ['<CR>'] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end
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
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
              },
              maxPreload = 100000,
              preloadFileSize = 10000,
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
    require("lualine").setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
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
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
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
    require("Comment").setup({
      padding = true,
      stickly = true,
      toggler = {
        line = "<leader>/",
      },
      opleader = {
        block = "<leader>/",
      },
      mappings = {
        basic = true,
        extra = false,
      },
    })
  end
}

local palette = {
  { "File",
    { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
    { "save current file (C-s)", ':w' },
    { "save all files (C-A-s)",  ':wa' },
    { "quit (C-q)",              ':qa' },
    { "file browser (C-i)",      ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
    { "search word (A-w)",       ":lua require('telescope.builtin').live_grep()",                  1 },
    { "git files (A-f)",         ":lua require('telescope.builtin').git_files()",                  1 },
    { "files (C-f)",             ":lua require('telescope.builtin').find_files()",                 1 },
  },
  { "Help",
    { "tips",            ":help tips" },
    { "cheatsheet",      ":help index" },
    { "tutorial",        ":help tutor" },
    { "summary",         ":help summary" },
    { "quick reference", ":help quickref" },
    { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
  },
  { "Vim",
    { "reload vimrc",              ":source $MYVIMRC" },
    { 'check health',              ":checkhealth" },
    { "jumps (Alt-j)",             ":lua require('telescope.builtin').jumplist()" },
    { "commands",                  ":lua require('telescope.builtin').commands()" },
    { "command history",           ":lua require('telescope.builtin').command_history()" },
    { "registers (A-e)",           ":lua require('telescope.builtin').registers()" },
    { "colorshceme",               ":lua require('telescope.builtin').colorscheme()",    1 },
    { "vim options",               ":lua require('telescope.builtin').vim_options()" },
    { "keymaps",                   ":lua require('telescope.builtin').keymaps()" },
    { "buffers",                   ":Telescope buffers" },
    { "search history (C-h)",      ":lua require('telescope.builtin').search_history()" },
    { "paste mode",                ':set paste!' },
    { 'cursor line',               ':set cursorline!' },
    { 'cursor column',             ':set cursorcolumn!' },
    { "spell checker",             ':set spell!' },
    { "relative number",           ':set relativenumber!' },
    { "search highlighting (F12)", ':set hlsearch!' },
  }
}

local telescope = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "LukasPietzschmann/telescope-tabs",
    "FeiyouG/command_center.nvim",
    "LinArcX/telescope-command-palette.nvim",
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    -- local m = { noremap = true, nowait = true }
    local builtin = require("telescope.builtin")
    local ts = require("telescope")
    ts.setup({
      defaults = {
        mappings = {
          i = {
            -- ["<C-h>"] = "which_key",
            ["<c-k>"] = "move_selection_previous",
            ["<c-j>"] = "move_selection_next",
            ["<c-h>"] = "preview_scrolling_up",
            ["<c-l>"] = "preview_scrolling_down",
            -- ["<esc>"] = "close",
          },
        },
        initial_mode = "normal",
        color_devicons = true,
        prompt_prefix = "🔍",
        selection_caret = " ",
        path_display = { "truncate" },
        pickers = {
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
          },
        }
      },
      extensions = {
        command_palette = palette,
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    ts.load_extension("telescope-tabs")
    ts.load_extension("command_palette")
    ts.load_extension("command_center")
    ts.load_extension('fzf')
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true, layout_config = { prompt_position = "top" } })
    end, m)
    vim.keymap.set("n", "<leader>fb", builtin.buffers, m)
  end,
}

local deus = {
  "theniceboy/nvim-deus",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd [[colorscheme deus]]
  end,
}

-- save cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = "*",
  callback = function()
    vim.cmd [[
    if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    ]]
  end
})

-- splite help vertically
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "help",
  callback = function()
    vim.cmd [[
    wincmd L
    vertical resize +15
    ]]
  end
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "markdown",
  callback = function()
    vim.o.linebreak = true
    vim.o.spell = true
    vim.o.shiftwidth = 2
    vim.o.tabstop = 2
    vim.o.softtabstop = 2
    vim.keymap.set("i", ";n", "<esc>/<++<cr>:noh<cr>cf>", m)
    vim.keymap.set("i", ";1", "# ", m)
    vim.keymap.set("i", ";2", "## ", m)
    vim.keymap.set("i", ";3", "### ", m)
    vim.keymap.set("i", ";4", "#### ", m)
    vim.keymap.set("i", ";5", "##### ", m)
    vim.keymap.set("i", ";6", "###### ", m)
    vim.keymap.set("i", ";b", "****<++++><esc>F*hi", m)
    vim.keymap.set("i", ";i", "**<++++><esc>F*i", m)
    vim.keymap.set("i", ";C", "``````<++++><esc>F`2hi", m)
    vim.keymap.set("i", ";c", "``<++++><esc>F`i", m)
    vim.keymap.set("i", ";I", "![](<++image-path++>)<esc>F]i", m)
    vim.keymap.set("i", ";u", "[](<++url++>)<esc>F]i", m)
    vim.keymap.set("i", ";t", "- [ ] ", m)
  end
})

vim.keymap.set("n", "S", ":w<cr>", m)
vim.keymap.set("n", "Q", ":q<cr>", m)
vim.keymap.set("n", "sk", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>")
vim.keymap.set("n", "sj", ":set splitbelow<CR>:split<CR>")
vim.keymap.set("n", "sh", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>")
vim.keymap.set("n", "sl", ":set splitright<CR>:vsplit<CR>")
vim.keymap.set("n", "<up>", ":res +5<CR>")
vim.keymap.set("n", "<down>", ":res -5<CR>")
vim.keymap.set("n", "<left>", ":vertical resize-5<CR>")
vim.keymap.set("n", "<right>", ":vertical resize+5<CR>")
vim.keymap.set("n", "tn", ":tabe<CR>")
vim.keymap.set("n", "tN", ":tab split<CR>")
vim.keymap.set("n", "th", ":-tabnext<CR>")
vim.keymap.set("n", "tl", ":+tabnext<CR>")
vim.keymap.set("n", "tmh", ":-tabmove<CR>")
vim.keymap.set("n", "tml", ":+tabmove<CR>")
vim.keymap.set({ "n", "v" }, "`", "~", m)
vim.keymap.set({ "n", "v" }, "<c-k>", "5<c-y>", m)
vim.keymap.set({ "n", "v" }, "<c-j>", "5<c-e>", m)
vim.keymap.set({ "n", "v" }, "J", "5j", m)
vim.keymap.set({ "n", "v" }, "K", "5k", m)
vim.keymap.set({ "n", "v" }, "H", "0", m)
vim.keymap.set({ "n", "v" }, "L", "$", m)
vim.keymap.set("n", "<esc>", ":nohlsearch<cr>", m)
vim.keymap.set("n", "<c-s>", "*N", m)
vim.keymap.set("n", "<leader>fm", function()
  vim.lsp.buf.format { async = true }
end, m)

require("lazy").setup({
  treesitter,
  deus,
  telescope,
  comment,
  lualine,
  mason,
  lsp,
  codeAction,
  surround,
  autopairs,
  nvimtree,
  bufferline,
  nvterm,
  fzf,
  wilder,
  dap,
})
