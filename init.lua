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
vim.opt.jumpoptions:append("stack")

local m = { noremap = true }

local outline = {
  'simrat39/symbols-outline.nvim',
  opts = {
    position = "left",
    width = 50,
    auto_close = true,
  },
}

local nio = {
  'nvim-neotest/nvim-nio',
}

local iw = {
  'Mr-LLLLL/interestingwords.nvim',
  config = function()
    require("interestingwords").setup {
      colors = { '#aeee00', '#ff0000', '#0000ff', '#b88823', '#ffa724', '#ff2c4b' },
      search_count = true,
      navigation = true,
      search_key = "<leader>m",
      cancel_search_key = "<leader>M",
      color_key = "<leader>w",
      cancel_color_key = "<leader>W",
    }
  end
}

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
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
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

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

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
      preselect = cmp.PreselectMode.None,
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
        { name = "luasnip" },
        { name = "nvim_lua" },
        { name = "path" },
        {
          name = 'tags',
          option = {
            -- this is the default options, change them if you want.
            -- Delayed time after user input, in milliseconds.
            complete_defer = 100,
            -- Max items when searching `taglist`.
            max_items = 10,
            -- The number of characters that need to be typed to trigger
            -- auto-completion.
            keyword_length = 3,
            -- Use exact word match when searching `taglist`, for better searching
            -- performance.
            exact_match = false,
            -- Prioritize searching result for current buffer.
            current_buffer_only = false,
          },
        },
      }, {
        { name = "buffer" },
      }),
      mapping = {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        --[[ ['<CR>'] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace })
            else
              fallback()
            end
          end
        }), ]]
        ["<Tab>"] = cmp.mapping(function(fallback)
          -- local ls = require("luasnip")
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn["vsnip#available"](1) == 1 then
            feedkey("<Plug>(vsnip-expand-or-jump)", "")
            --[[ elseif has_words_before() then
            cmp.complete() ]]
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn["vsnip#jumpable"](-1) == 1 then
            feedkey("<Plug>(vsnip-jump-prev)", "")
          end
        end, { "i", "s" }),
      }
    })

    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
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

local luasnip = {
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp"
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
      new = require("telescope.actions").select_tab_drop
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
            ["<c-o>"] = new,
            -- ["<esc>"] = "close",
            ["<cr>"] = actions.select_default,
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

local flutter = {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim', -- optional for vim.ui.select
  },
  config = function()
    require("flutter-tools").setup {
      dev_log = {
        enabled = true,
        filter = function(log_line)
          if log_line and log_line:match("MESA") then
            return false
          end
          return true
        end, -- optional callback to filter the log
        -- takes a log_line as string argument; returns a boolean or nil;
        -- the log_line is only added to the output if the function returns true
        notify_errors = false, -- if there is an error whilst running then notify the user
        open_cmd = "vsplit",   -- command to use to open the log buffer
        focus_on_open = true,  -- focus on the newly opened log window
      }
    }
  end,
}
local logHL = {
  'fei6409/log-highlight.nvim',
  config = function()
    require('log-highlight').setup {
      -- The following options support either a string or a table of strings.

      -- The file extensions.
      extension = 'log',

      -- The file names or the full file paths.
      filename = {
        'messages',
      },

      -- The file path glob patterns, e.g. `.*%.lg`, `/var/log/.*`.
      -- Note: `%.` is to match a literal dot (`.`) in a pattern in Lua, but most
      -- of the time `.` and `%.` here make no observable difference.
      pattern = {
        '/var/log/.*',
        'messages%..*',
      },
    }
  end,
}

local zen = {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      width = .6
    }
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}

local tags = {
  "quangnguyen30192/cmp-nvim-tags",
}

local colorizer = {
  'norcalli/nvim-colorizer.lua',
  config = function()
    require 'colorizer'.setup()
  end
}

local trouble = {
  "folke/trouble.nvim",
  opts = {
    auto_close = false,    -- auto close when there are no items
    auto_open = false,     -- auto open when there are items
    auto_preview = true,   -- automatically open preview when on an item
    auto_refresh = true,   -- auto refresh when open
    auto_jump = false,     -- auto jump to the item when there's only one
    focus = true,         -- Focus the window when opened
    restore = true,        -- restores the last location in the list when opening
    follow = true,         -- Follow the current item
    indent_guides = true,  -- show indent guides
    max_items = 200,       -- limit number of items that can be displayed per section
    multiline = true,      -- render multi-line messages
    pinned = false,        -- When pinned, the opened trouble window will be bound to the current buffer
    warn_no_results = true, -- show a warning when there are no results
    open_no_results = false, -- open the trouble window when there are no results
    win = {},              -- window options for the results window. Can be a split or a floating window.
    -- Window options for the preview window. Can be a split, floating window,
    -- or `main` to show the preview in the main editor window.
    preview = {
      type = "main",
      -- when a buffer is not yet loaded, the preview window will be created
      -- in a scratch buffer with only syntax highlighting enabled.
      -- Set to false, if you want the preview to always be a real loaded buffer.
      scratch = true,
    },
    -- Throttle/Debounce settings. Should usually not be changed.
    throttle = {
      refresh = 20,                          -- fetches new data when needed
      update = 10,                           -- updates the window
      render = 10,                           -- renders the window
      follow = 100,                          -- follows the current item
      preview = { ms = 100, debounce = true }, -- shows the preview for the current item
    },
    -- Key mappings can be set to the name of a builtin action,
    -- or you can define your own custom action.
    keys = {
      ["?"] = "help",
      r = "refresh",
      R = "toggle_refresh",
      q = "close",
      o = "jump_close",
      ["<esc>"] = "cancel",
      ["<cr>"] = "jump",
      ["<2-leftmouse>"] = "jump",
      ["<c-s>"] = "jump_split",
      ["<c-v>"] = "jump_vsplit",
      -- go down to next item (accepts count)
      -- j = "next",
      ["}"] = "next",
      ["]]"] = "next",
      -- go up to prev item (accepts count)
      -- k = "prev",
      ["{"] = "prev",
      ["[["] = "prev",
      dd = "delete",
      d = { action = "delete", mode = "v" },
      i = "inspect",
      p = "preview",
      P = "toggle_preview",
      zo = "fold_open",
      zO = "fold_open_recursive",
      zc = "fold_close",
      zC = "fold_close_recursive",
      za = "fold_toggle",
      zA = "fold_toggle_recursive",
      zm = "fold_more",
      zM = "fold_close_all",
      zr = "fold_reduce",
      zR = "fold_open_all",
      zx = "fold_update",
      zX = "fold_update_all",
      zn = "fold_disable",
      zN = "fold_enable",
      zi = "fold_toggle_enable",
      gb = { -- example of a custom action that toggles the active view filter
        action = function(view)
          view:filter({ buf = 0 }, { toggle = true })
        end,
        desc = "Toggle Current Buffer Filter",
      },
      s = { -- example of a custom action that toggles the severity
        action = function(view)
          local f = view:get_filter("severity")
          local severity = ((f and f.filter.severity or 0) + 1) % 5
          view:filter({ severity = severity }, {
            id = "severity",
            template = "{hl:Title}Filter:{hl} {severity}",
            del = severity == 0,
          })
        end,
        desc = "Toggle Severity Filter",
      },
    },
    modes = {
      -- sources define their own modes, which you can use directly,
      -- or override like in the example below
      lsp_references = {
        -- some modes are configurable, see the source code for more details
        params = {
          include_declaration = true,
        },
      },
      -- The LSP base mode for:
      -- * lsp_definitions, lsp_references, lsp_implementations
      -- * lsp_type_definitions, lsp_declarations, lsp_command
      lsp_base = {
        params = {
          -- don't include the current location in the results
          include_current = false,
        },
      },
      -- more advanced example that extends the lsp_document_symbols
      symbols = {
        desc = "document symbols",
        mode = "lsp_document_symbols",
        focus = false,
        win = { position = "right" },
        filter = {
          -- remove Package since luals uses it for control flow structures
          ["not"] = { ft = "lua", kind = "Package" },
          any = {
            -- all symbol kinds for help / markdown files
            ft = { "help", "markdown" },
            -- default set of symbol kinds
            kind = {
              "Class",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
              -- "Variable",
            },
          },
        },
      },
    },
    -- stylua: ignore
    icons = {
      indent        = {
        top         = "│ ",
        middle      = "├╴",
        last        = "└╴",
        -- last          = "-╴",
        -- last       = "╰╴", -- rounded
        fold_open   = " ",
        fold_closed = " ",
        ws          = "  ",
      },
      folder_closed = " ",
      folder_open   = " ",
      kinds         = {
        Array         = " ",
        Boolean       = "󰨙 ",
        Class         = " ",
        Constant      = "󰏿 ",
        Constructor   = " ",
        Enum          = " ",
        EnumMember    = " ",
        Event         = " ",
        Field         = " ",
        File          = " ",
        Function      = "󰊕 ",
        Interface     = " ",
        Key           = " ",
        Method        = "󰊕 ",
        Module        = " ",
        Namespace     = "󰦮 ",
        Null          = " ",
        Number        = "󰎠 ",
        Object        = " ",
        Operator      = " ",
        Package       = " ",
        Property      = " ",
        String        = " ",
        Struct        = "󰆼 ",
        TypeParameter = " ",
        Variable      = "󰀫 ",
      },
    },
  },
  cmd = "Trouble",
  keys = {
    {
      "<leader>d",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=true<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
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
    vim.o.shiftwidth = 4
    vim.o.tabstop = 4
    vim.o.softtabstop = 4
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
    vim.keymap.set('n', 'gD', ":lua vim.lsp.buf.declaration({reuse_win = true})<CR>", opts)
    vim.keymap.set('n', 'gd', ":lua vim.lsp.buf.definition({reuse_win = true})<CR>", opts)
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
    vim.keymap.set('n', 'gc', function()
      vim.cmd [[
      wincmd j
      quit
      ]]
    end, opts)

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
    vim.system({ "fcitx5-remote", "-c" })
  end,
})

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

  if ft == "c" then
    require("nvterm.terminal").send("m", "vertical")
    vim.cmd [[wincmd w]]
    --[[ split()
    vim.cmd("term make") ]]
  end
end

local compileRunTest = function()
  vim.cmd("w")
  -- check file type
  local ft = vim.bo.filetype
  if ft == "go" then
    require("nvterm.terminal").send("make test", "vertical")
    vim.cmd [[wincmd w]]
    --[[ split()
    vim.cmd("term make") ]]
  end
end

-- pre-keymap
vim.keymap.set("n", "s", "<nop>", m)
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
vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, m)
vim.keymap.set("n", "<leader>in", function() require('lsp-inlayhints').toggle() end, m)
vim.keymap.set("n", "<leader>h", ":%!xxd -a -u -g 2 -e<cr>")
vim.keymap.set("n", "<leader>z", function() require("zen-mode").toggle({ window = { width = .6 } }) end, m)
vim.keymap.set('n', 'rr', compileRun, { silent = true })
vim.keymap.set('n', 'rt', compileRunTest, { silent = true })
vim.keymap.set('n', '<leader>o', ":SymbolsOutline<cr>", { silent = true })
vim.keymap.set('n', '<leader>xx', "<cmd>source %<cr>", { silent = true })
vim.keymap.set('n', '<leader>x', ":.lua<cr>", { silent = true })
vim.keymap.set('v', '<leader>x', ":lua<cr>", { silent = true })

local myPlugin = {
  "test.nvim",
  dir = "~/Workspace/code/lua/nvim-plugins/test.nvim",
  config = function()
    vim.keymap.set("n", ";t", function()
      require("test").open_floating_window()
    end)
  end,
}


require("lazy").setup({
  -- myPlugin,
  trouble,
  colorizer,
  luasnip,
  tags,
  zen,
  logHL,
  flutter,
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
  iw,
  outline,
  nio,
})

-- vim.cmd("highlight Normal guibg=none")
