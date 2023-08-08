local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
vim.o.showmode = false
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
vim.o.list = true
vim.o.listchars = "tab:> ,trail:▫"
vim.o.clipboard = "unnamedplus"
vim.o.scrolloff = 7

local m = { noremap = true }

local dropbar = {
  "Bekaboo/dropbar.nvim",
  commit = "19011d96959cd40a7173485ee54202589760caae",
  config = function()
    local api = require("dropbar.api")
    vim.keymap.set('n', '<Leader>;', api.pick)
    vim.keymap.set('n', '[c', api.goto_context_start)
    vim.keymap.set('n', ']c', api.select_next_context)

    local confirm = function()
      local menu = api.get_current_dropbar_menu()
      if not menu then
        return
      end
      local cursor = vim.api.nvim_win_get_cursor(menu.win)
      local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
      if component then
        menu:click_on(component)
      end
    end

    local quit_curr = function()
      local menu = api.get_current_dropbar_menu()
      if menu then
        menu:close()
      end
    end

    require("dropbar").setup({
      menu = {
        -- When on, automatically set the cursor to the closest previous/next
        -- clickable component in the direction of cursor movement on CursorMoved
        quick_navigation = true,
        ---@type table<string, string|function|table<string, string|function>>
        keymaps = {
          ['<LeftMouse>'] = function()
            local menu = api.get_current_dropbar_menu()
            if not menu then
              return
            end
            local mouse = vim.fn.getmousepos()
            if mouse.winid ~= menu.win then
              local parent_menu = api.get_dropbar_menu(mouse.winid)
              if parent_menu and parent_menu.sub_menu then
                parent_menu.sub_menu:close()
              end
              if vim.api.nvim_win_is_valid(mouse.winid) then
                vim.api.nvim_set_current_win(mouse.winid)
              end
              return
            end
            menu:click_at({ mouse.line, mouse.column }, nil, 1, 'l')
          end,
          ['<CR>'] = confirm,
          ['i'] = confirm,
          ['<esc>'] = quit_curr,
          ['q'] = quit_curr,
          ['n'] = quit_curr,
          ['<MouseMove>'] = function()
            local menu = api.get_current_dropbar_menu()
            if not menu then
              return
            end
            local mouse = vim.fn.getmousepos()
            if mouse.winid ~= menu.win then
              return
            end
            menu:update_hover_hl({ mouse.line, mouse.column - 1 })
          end,
        },
      },
    })
  end
}

local test = function()
  local buf = vim.api.nvim_create_buf({}, {})
  print(buf)
end

vim.keymap.set("n", "tt", test, m)

local trouble = {
  "folke/trouble.nvim",
  dependencies = {
    "folke/lsp-colors.nvim",
    config = function()
      require("lsp-colors").setup({
        Error = "#db4b4b",
        Warning = "#e0af68",
        Information = "#0db9d7",
        Hint = "#10B981"
      })
    end
  },
  config = function()
    require("trouble").setup({
      padding = false,
      cycle_results = false,
    })
  end
}

local dap = {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    vim.keymap.set("n", ";q", ":Telescope dap<CR>", m)
    vim.keymap.set("n", ";b", dap.toggle_breakpoint, m)
    vim.keymap.set("n", ";n", dap.continue, m)
    vim.keymap.set("n", ";s", dap.terminate, m)
    vim.keymap.set("n", ";d", dapui.toggle, m)

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

    require("mason-nvim-dap").setup({
      ensure_installed = { "delve", "codelldb", "cpptools" },
      automatic_installation = true,
      handlers = {
        function(config)
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
          -- layout = 'vertical',
          layout = 'horizontal',
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
          ["<c-l>"]    = "preview-page-down",
          ["<c-h>"]    = "preview-page-up",
          ["<S-left>"] = "preview-page-reset",
        },
        fzf = {
          ["esc"]    = "abort",
          ["ctrl-d"] = "unix-line-discard",
          -- ["ctrl-h"]     = "half-page-down",
          -- ["ctrl-l"]     = "half-page-up",
          ["ctrl-i"] = "beginning-of-line",
          ["ctrl-a"] = "end-of-line",
          -- ["alt-a"]      = "toggle-all",
          -- ["f3"]         = "toggle-preview-wrap",
          -- ["f4"]         = "toggle-preview",
          -- ["shift-down"] = "preview-page-down",
          -- ["shift-up"]   = "preview-page-up",
          ["ctrl-j"] = "down",
          ["ctrl-k"] = "up",
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
    --[[ vim.keymap.set("n", "<leader>h", function()
      require("nvterm.terminal").toggle "horizontal"
    end, m) ]]
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
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    local function my_on_attach(bufnr)
      local api = require "nvim-tree.api"
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
      -- custom mappings
      vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up to root dir'))
      vim.keymap.set('n', '=', api.tree.change_root_to_node, opts('Into node dir'))
      vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      vim.keymap.set('n', 'l', api.node.open.tab, opts('Open: New Tab'))
      vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
      vim.keymap.set('n', 'o', api.node.open.tab, opts('Open: New Tab'))
      vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
    end
    require("nvim-tree").setup({
      on_attach = my_on_attach,
      sort_by = "case_sensitive",
      hijack_cursor = true,
      renderer = {
        group_empty = false,
        root_folder_label = false,
        indent_markers = {
          enable = true,
        },
      },
      filters = {
        dotfiles = true,
      },
      disable_netrw = true,
    })
  end
}

local treesitter = {
  -- "nvim-treesitter/playground",
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      -- ensure_installed = { "query", "lua", "go" },
      ensure_installed = { "lua", "go", "c" },
      highlight = {
        enable = true,
        -- use_languagetree = true,
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
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "simrat39/inlay-hints.nvim",
    {
      "lvimuser/lsp-inlayhints.nvim",
      branch = "anticonceal",
    },
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
        { name = "nvim_lua" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
      mapping = {
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace })
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
    local servers = { "lua_ls", "gopls", "clangd" }
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                [vim.fn.expand(vim.fn.stdpath("config"))] = true,
              },
              maxPreload = 100000,
              preloadFileSize = 10000,
            }
          }
        }
      })
    end

    require("lsp-inlayhints").setup {
      enabled_at_startup = false,
      debug_mode = true,
    }
    require("inlay-hints").setup()
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
    local actions = require("telescope.actions")
    local ts = require("telescope")
    local new

    if true then
      new = require("telescope.actions").select_tab
    else
      new = require("telescope.actions").select_default
    end

    ts.setup({
      defaults = {
        sorting_strategy = "ascending",
        mappings = {
          i = {
            -- ["<C-h>"] = "which_key",
            ["<c-k>"] = "move_selection_previous",
            ["<c-j>"] = "move_selection_next",
            ["<c-h>"] = "preview_scrolling_up",
            ["<c-l>"] = "preview_scrolling_down",
            ["<CR>"] = actions.select_tab,
            -- ["<esc>"] = "close",
            ["<cr>"] = new,
          },
          n = {
            --[[ ["<cr>"] = function()
              if true then
                return require('telescope.actions').select_default
              end
              return require('telescope.actions').select_tab
            end, ]]
          },
        },
        initial_mode = "insert",
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
    vim.keymap.set("n", "<leader>sf", function()
      builtin.find_files({ hidden = true, layout_config = { prompt_position = "top" } })
    end, m)
    vim.keymap.set("n", "<leader>sh", function()
      builtin.help_tags()
    end, m)
    vim.keymap.set("n", "<leader>sb", builtin.buffers, m)
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
  command = [[
    if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    ]],
})
-- vim.api.nvim_create_autocmd({ "BufReadPost" }, {
-- pattern = "*",
-- command = "",
-- callback = function()
-- vim.cmd [[
-- if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
-- ]]
-- end
-- })

-- splite help vertically
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = "*.txt",
  command = "wincmd T",
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*.go",
  callback = function()
    vim.cmd [[
    write
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

vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlayhints",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lsp-inlayhints").on_attach(client, bufnr)
    vim.cmd("hi link LspInlayHint Comment")
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<c-h>', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', ":CodeActionMenu<cr>", opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*.go",
  command = "write",
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.system({ "fcitx-remote", "-c" })
  end,
})

-- pre-keymap
vim.keymap.set("n", "S", ":w<cr>", m)
vim.keymap.set("n", "Q", ":q<cr>", m)
vim.keymap.set("n", "tt", ":NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>w", "<C-w>w")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>l", "<C-w>l")
vim.keymap.set("n", "sk", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>")
vim.keymap.set("n", "sj", ":set splitbelow<CR>:split<CR>")
vim.keymap.set("n", "sh", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>")
vim.keymap.set("n", "sl", ":set splitright<CR>:vsplit<CR>")
vim.keymap.set("n", "<up>", ":res +5<CR>")
vim.keymap.set("n", "<down>", ":res -5<CR>")
vim.keymap.set("n", "<left>", ":vertical resize-5<CR>")
vim.keymap.set("n", "<right>", ":vertical resize+5<CR>")
vim.keymap.set("n", "gn", ":tabnew<CR>")
vim.keymap.set("n", "gs", ":tab split<CR>")
vim.keymap.set("n", "gh", ":tabprevious<CR>")
vim.keymap.set("n", "gl", ":tabnext<CR>")
vim.keymap.set("n", "gmh", ":-tabmove<CR>")
vim.keymap.set("n", "gml", ":+tabmove<CR>")
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
vim.keymap.set("n", "<leader>in", function()
  require('lsp-inlayhints').toggle()
end, m)

P = function(v)
  print(vim.inspect(v))
  return v
end


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
  dropbar,
  {
    "test.nvim",
    dir = "/home/stan/Workspace/code/lua/nvim-plugins/test.nvim",
    config = function()
      vim.keymap.set("n", ";t", function()
        require("test").test()
      end)
    end,
  },
})

--[[ local split = function()
  vim.cmd("set splitbelow")
  vim.cmd("sp")
  vim.cmd("res -5")
end ]]
local compileRun = function()
  vim.cmd("w")
  -- check file type
  local ft = vim.bo.filetype
  if ft == "go" then
    require("nvterm.terminal").send("make", "vertical")
    vim.cmd [[wincmd w]]
    --[[ split()
    vim.cmd("term make") ]]
  end
end

vim.keymap.set('n', 'r', compileRun, { silent = true })
